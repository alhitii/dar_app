// ✅ Firebase Cloud Functions v2 - جميع الميزات في ملف واحد
import { onDocumentCreated, onDocumentUpdated, onDocumentWritten } from "firebase-functions/v2/firestore";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { initializeApp } from "firebase-admin/app";
import { getFirestore, FieldValue } from "firebase-admin/firestore";
import { getAuth } from "firebase-admin/auth";
import { getMessaging } from "firebase-admin/messaging";

initializeApp();
const db = getFirestore();
const auth = getAuth();
const messaging = getMessaging();

// 🟦 وظيفة مساعدة لتسجيل الأحداث
async function logAction(type, details) {
  try {
    await db.collection("logs").add({
      type,
      details,
      timestamp: FieldValue.serverTimestamp(),
    });
  } catch (err) {
    console.error("⚠️ Failed to log action:", err);
  }
}

// 🟢 1. إنشاء المستخدم تلقائيًا
export const autoCreateUser = onDocumentCreated("users_emails/{email}", async (event) => {
  const data = event.data?.data();
  if (!data?.email || !data?.initialPassword) return;

  try {
    let userRecord;
    try {
      userRecord = await auth.getUserByEmail(data.email);
    } catch {
      userRecord = await auth.createUser({
        email: data.email,
        password: data.initialPassword,
        displayName: data.name || "",
      });
    }

    await db.collection("users").doc(userRecord.uid).set({
      email: data.email,
      name: data.name || "",
      role: data.role || "student",
      subjects: data.subjects || [],
      grade: data.grade || "",
      section: data.section || "",
      createdAt: FieldValue.serverTimestamp(),
    });

    console.log(`✅ User created successfully: ${data.email}`);
    await logAction("create_user", { email: data.email, role: data.role });
  } catch (err) {
    console.error("❌ Error creating user:", err);
    await logAction("error_create_user", { error: err.message, email: data.email });
  }
});

// 🟡 2. تحديث مواد المعلّم
export const syncTeacherSubjects = onDocumentWritten("users/{userId}", async (event) => {
  const newData = event.data?.after.data();
  const previousData = event.data?.before.data();

  if (!newData || newData.role !== "teacher") return;

  try {
    const subjects = newData.subjects || [];
    const oldSubjects = previousData?.subjects || [];

    const batch = db.batch();

    // حذف المواد التي تم إزالتها فقط (الموجودة في القديم وليست في الجديد)
    const removedSubjects = oldSubjects.filter(id => !subjects.includes(id));
    for (const subjectId of removedSubjects) {
      const subjectRef = db.collection("subjects").doc(subjectId);
      batch.update(subjectRef, {
        teacherId: FieldValue.delete(),
        teacherName: FieldValue.delete()
      });
    }

    // تحديث جميع المواد الحالية
    for (const subjectId of subjects) {
      const subjectRef = db.collection("subjects").doc(subjectId);
      batch.update(subjectRef, {
        teacherId: event.params.userId,
        teacherName: newData.name,
        lastUpdated: FieldValue.serverTimestamp()
      });
    }

    await batch.commit();
    console.log(`✅ Teacher ${newData.name} subjects synced: ${subjects.length} subjects`);
    
  } catch (err) {
    console.error("❌ Error syncing teacher subjects:", err);
  }
});

// 🔴 3. إرسال إشعار عند إضافة واجب
export const notifyStudentsOnHomework = onDocumentCreated("homework/{homeworkId}", async (event) => {
  const data = event.data?.data();
  if (!data?.subjectName || !data?.title) return;

  try {
    console.log(`📚 New homework: ${data.subjectName} - ${data.title}`);
    console.log(`   Grade: ${data.grade}, Sections: ${data.sections}`);

    // جلب الطلاب حسب grade والشعب المحددة
    const grade = data.grade;
    const sections = data.sections || []; // array of sections

    if (sections.length === 0) {
      console.log("⚠️ No sections specified");
      return;
    }

    // جلب جميع الطلاب في هذا الصف
    const studentsSnap = await db
      .collection("users")
      .where("role", "==", "student")
      .where("grade", "==", grade)
      .get();

    // ✅ إرسال لكل شعبة عبر Topic (طريقة المشروع القديم)
    let successCount = 0;
    let failedCount = 0;

    for (const section of sections) {
      // ✅ تحويل الأحرف العربية إلى ASCII (نفس طريقة التطبيق)
      const gradeEncoded = encodeURIComponent(grade);
      const sectionEncoded = encodeURIComponent(section);
      const topic = `g_${gradeEncoded}_s_${sectionEncoded}`;
      
      const message = {
        notification: {
          title: `${data.subjectEmoji || '📘'} واجب جديد في مادة ${data.subjectName}`,
          body: data.title || "تمت إضافة واجب جديد، تحقق الآن من التطبيق.",
        },
        data: {
          sound: "default",
          channel_id: "school_notifications_v2",
          priority: "high",
          click_action: "FLUTTER_NOTIFICATION_CLICK",
          notification_foreground: "true"
        },
        android: {
          priority: "high",
          notification: {
            sound: "default",
            channelId: "school_notifications_v2",
            priority: "high",
            visibility: "public",
            defaultSound: true,
            defaultVibrateTimings: true
          },
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              badge: 1,
              contentAvailable: true
            },
          },
        },
        topic: topic, // ✅ إرسال للـ Topic مباشرة
      };

      try {
        await messaging.send(message);
        successCount++;
        console.log(`✅ تم إرسال إشعار للـ Topic: ${topic}`);
      } catch (err) {
        failedCount++;
        console.error(`❌ خطأ في إرسال للـ Topic ${topic}:`, err.message);
      }
    }

    console.log(`✅ Homework notifications: ${successCount} success, ${failedCount} failed`);
    
    await logAction("homework_notify", {
      subject: data.subjectName,
      success: successCount,
      failed: failedCount,
    });
  } catch (err) {
    console.error("❌ Error sending homework notifications:", err);
    await logAction("error_homework_notify", { error: err.message });
  }
});

// 📢 4. إرسال إشعار عند نشر إعلان إداري
export const notifyOnAnnouncement = onDocumentCreated("announcements/{announcementId}", async (event) => {
  const data = event.data?.data();
  if (!data?.title || !data?.message) return;

  try {
    const targetRole = data.targetRole || "student";
    
    // ✅ تحديد Topics حسب الدور
    let topics = [];
    if (targetRole === "student") {
      topics = ["students"];
    } else if (targetRole === "teacher") {
      topics = ["teachers"];
    } else if (targetRole === "all") {
      topics = ["students", "teachers", "admins"];
    }

    // تحديد emoji حسب نوع الإعلان
    let emoji = "📢";
    if (data.type === "success") emoji = "✅";
    else if (data.type === "warning") emoji = "⚠️";
    else if (data.type === "error") emoji = "❌";
    else if (data.type === "info") emoji = "ℹ️";

    // ✅ إرسال لكل Topic
    let successCount = 0;
    let failedCount = 0;

    for (const topic of topics) {
      try {
        const message = {
          notification: {
            title: `${emoji} ${data.title}`,
            body: data.message,
          },
          data: {
            sound: "default",
            channel_id: "school_notifications_v2",
            priority: "high",
            click_action: "FLUTTER_NOTIFICATION_CLICK",
            notification_foreground: "true",
            type: "announcement",
            announcement_type: data.type || "info"
          },
          android: {
            priority: "high",
            notification: {
              sound: "default",
              channelId: "school_notifications_v2",
              priority: "high",
              defaultSound: true,
              defaultVibrateTimings: true
            },
          },
          apns: {
            payload: {
              aps: {
                sound: "default",
                badge: 1,
                contentAvailable: true
              },
            },
          },
          topic: topic,
        };

        await messaging.send(message);
        console.log(`✅ Announcement sent to topic: ${topic}`);
        successCount++;
      } catch (err) {
        console.error(`❌ Failed to send to topic ${topic}:`, err);
        failedCount++;
      }
    }

    console.log(`✅ Announcement notifications: ${successCount} success, ${failedCount} failed`);
    await logAction("announcement_notify", {
      title: data.title,
      targetRole,
      topics: topics.join(", "),
      success: successCount,
      failed: failedCount,
    });
  } catch (err) {
    console.error("❌ Error sending announcement notifications:", err);
    await logAction("error_announcement_notify", { error: err.message });
  }
});

// ✅ 5. إرسال إشعار عند تسجيل غياب (باستخدام Topics)
export const notifyOnAbsence = onDocumentCreated("absences/{absenceId}", async (event) => {
  const data = event.data?.data();
  console.log(`🔍 notifyOnAbsence triggered with data:`, JSON.stringify(data));
  
  if (!data?.studentUid || !data?.message) {
    console.log(`⚠️ Missing required fields: studentUid=${data?.studentUid}, message=${data?.message}`);
    return;
  }

  try {
    console.log(`📢 Absence notification for student: ${data.studentUid}`);
    
    // ✅ إرسال للطالب المحدد عبر Topic
    const topic = `student_${data.studentUid}`;
    console.log(`📤 Sending to topic: ${topic}`);

    const message = {
      notification: {
        title: `⚠️ تنبيه غياب - ${data.date || "اليوم"}`,
        body: data.message,
      },
      data: {
        sound: "default",
        channel_id: "school_notifications_v2",
        priority: "high",
        click_action: "FLUTTER_NOTIFICATION_CLICK",
        notification_foreground: "true",
        type: "absence",
        student_name: data.studentName || "",
        date: data.date || ""
      },
      android: {
        priority: "high",
        notification: {
          sound: "default",
          channelId: "school_notifications_v2",
          priority: "high",
          defaultSound: true,
          defaultVibrateTimings: true
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
            contentAvailable: true
          },
        },
      },
      topic: topic, // ✅ إرسال للـ Topic مباشرة
    };

    await messaging.send(message);
    console.log(`✅ Absence notification sent to topic: ${topic}`);
    
    await logAction("absence_notify", {
      student: data.studentName,
      date: data.date,
      topic: topic,
    });
  } catch (err) {
    console.error("❌ Error sending absence notification:", err);
    await logAction("error_absence_notify", { error: err.message });
  }
});

// 🗑️ 6. حذف مستخدم بالكامل من Authentication و Firestore
export const deleteUserCompletely = onCall(async (request) => {
  const { uid, role, email } = request.data;

  // التحقق من صحة البيانات
  if (!uid || typeof uid !== 'string') {
    throw new HttpsError("invalid-argument", "UID مطلوب ويجب أن يكون نصاً");
  }

  console.log(`🗑️ بدء حذف المستخدم: ${email} (${role}) - UID: ${uid}`);

  try {

    // 1. حذف من users collection
    await db.collection("users").doc(uid).delete();
    console.log(`✅ User deleted from users collection: ${email} (UID: ${uid})`);

    // 2. حذف من المجموعة الخاصة بالدور
    if (role === 'student') {
      await db.collection("students").doc(uid).delete();
      console.log(`✅ Deleted from students collection`);
    } else if (role === 'teacher') {
      await db.collection("teachers").doc(uid).delete();
      console.log(`✅ Deleted from teachers collection`);
    } else if (role === 'admin') {
      await db.collection("admins").doc(uid).delete();
      console.log(`✅ Deleted from admins collection`);
    }

    // 3. حذف البيانات المرتبطة
    if (role === 'teacher') {
      // حذف مواد المعلم
      const subjectsSnapshot = await db
        .collection('subjects')
        .where('teacherId', '==', uid)
        .get();
      
      const batch = db.batch();
      subjectsSnapshot.docs.forEach(doc => {
        batch.delete(doc.ref);
      });
      await batch.commit();
      console.log(`✅ Deleted ${subjectsSnapshot.size} subjects for teacher`);
    } else if (role === 'student') {
      // حذف واجبات الطالب
      const homeworkSnapshot = await db
        .collection('homework')
        .where('studentId', '==', uid)
        .get();
      
      const batch = db.batch();
      homeworkSnapshot.docs.forEach(doc => {
        batch.delete(doc.ref);
      });
      await batch.commit();
      console.log(`✅ Deleted ${homeworkSnapshot.size} homework for student`);
    }

    // حذف من Authentication أخيراً
    try {
      await auth.deleteUser(uid);
      console.log(`✅ User deleted from Authentication: ${email} (UID: ${uid})`);
    } catch (authError) {
      console.warn(`⚠️ Could not delete from Authentication (may not exist): ${authError.message}`);
    }

    await logAction("delete_user_completely", {
      email,
      uid,
      role,
      deletedBy: request.auth?.uid || 'system'
    });

    return {
      success: true,
      message: `تم حذف ${email} بنجاح من Authentication و Firestore`
    };
  } catch (error) {
    console.error("❌ Error deleting user completely:", error);
    await logAction("error_delete_user_completely", {
      error: error.message,
      email,
      uid,
      role
    });

    // إعادة رمي الأخطاء المعروفة
    if (error.code) {
      throw error;
    }

    throw new HttpsError("internal", `فشل حذف المستخدم: ${error.message}`);
  }
});

// 🗑️ 7. حذف مستخدم من Authentication فقط (يتطلب صلاحيات Admin)
export const deleteUser = onCall(async (request) => {
  // التحقق من أن المستدعي مسجل دخول
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "يجب تسجيل الدخول لحذف المستخدمين");
  }

  const { uid, email } = request.data;

  // التحقق من صحة البيانات
  if (!uid || typeof uid !== 'string' || !email || typeof email !== 'string') {
    throw new HttpsError("invalid-argument", "UID و Email مطلوبان ويجب أن يكونا نصوصاً");
  }

  try {
    // التحقق من أن المستدعي هو admin
    const callerUid = request.auth.uid;
    const callerDoc = await db.collection("users").doc(callerUid).get();

    if (!callerDoc.exists) {
      throw new HttpsError("permission-denied", "حساب المدير غير موجود");
    }

    const callerData = callerDoc.data();
    if (callerData.role !== "admin") {
      throw new HttpsError("permission-denied", "يجب أن تكون مسؤولاً لحذف المستخدمين");
    }

    // التحقق من أن المستخدم المراد حذفه موجود
    const targetUserDoc = await db.collection("users").doc(uid).get();
    if (!targetUserDoc.exists) {
      throw new HttpsError("not-found", "المستخدم المطلوب حذفه غير موجود");
    }

    // منع حذف الإدمن الخاص بالنظام
    const targetData = targetUserDoc.data();
    if (targetData.role === "admin" && callerUid === uid) {
      throw new HttpsError("permission-denied", "لا يمكنك حذف حسابك الخاص");
    }

    // حذف من Authentication
    await auth.deleteUser(uid);

    console.log(`✅ User deleted from Authentication: ${email} (UID: ${uid})`);
    await logAction("delete_user_auth", {
      email,
      uid,
      deletedBy: request.auth.token.email || callerUid
    });

    return {
      success: true,
      message: `تم حذف المستخدم ${email} من Authentication بنجاح`
    };
  } catch (error) {
    console.error("❌ Error deleting user from Authentication:", error);
    await logAction("error_delete_user", {
      error: error.message,
      email,
      uid
    });

    // إعادة رمي الأخطاء المعروفة
    if (error.code) {
      throw error;
    }

    throw new HttpsError("internal", `فشل حذف المستخدم: ${error.message}`);
  }
});

// 🔄 9. تحديث جميع المواد بأسماء المعلمين
export const updateAllSubjectsWithTeachers = onCall(async (request) => {
  // التحقق من أن المستدعي مسجل دخول
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "يجب تسجيل الدخول");
  }

  try {
    console.log('🔄 بدء تحديث جميع المواد بأسماء المعلمين...');
    
    // جلب جميع المعلمين
    const teachersSnapshot = await db.collection('users')
      .where('role', '==', 'teacher')
      .get();
    
    console.log(`👨‍🏫 عدد المعلمين: ${teachersSnapshot.size}`);
    
    let updatedCount = 0;
    
    // لكل معلم
    for (const teacherDoc of teachersSnapshot.docs) {
      const teacherData = teacherDoc.data();
      const teacherId = teacherDoc.id;
      const teacherName = teacherData.name;
      const teacherSubjects = teacherData.subjects || [];
      
      console.log(`👨‍🏫 معالجة المعلم: ${teacherName} (${teacherSubjects.length} مادة)`);
      
      // تحديث كل مادة من مواد المعلم
      for (const subjectId of teacherSubjects) {
        try {
          const subjectRef = db.collection('subjects').doc(subjectId);
          const subjectDoc = await subjectRef.get();
          
          if (subjectDoc.exists) {
            await subjectRef.update({
              teacherId: teacherId,
              teacherName: teacherName,
              lastUpdated: FieldValue.serverTimestamp()
            });
            
            const subjectName = subjectDoc.data().name;
            console.log(`  ✅ تم تحديث: ${subjectName} → ${teacherName}`);
            updatedCount++;
          } else {
            console.log(`  ⚠️ المادة غير موجودة: ${subjectId}`);
          }
        } catch (err) {
          console.error(`  ❌ خطأ في تحديث المادة ${subjectId}:`, err);
        }
      }
    }
    
    console.log(`✅ تم تحديث ${updatedCount} مادة بنجاح`);
    
    await logAction("update_all_subjects_teachers", {
      teachersCount: teachersSnapshot.size,
      updatedCount: updatedCount
    });
    
    return {
      success: true,
      message: `تم تحديث ${updatedCount} مادة بأسماء المعلمين`,
      teachersCount: teachersSnapshot.size,
      updatedCount: updatedCount
    };
    
  } catch (error) {
    console.error("❌ خطأ في تحديث المواد:", error);
    await logAction("error_update_subjects_teachers", { error: error.message });
    
    throw new HttpsError("internal", `فشل تحديث المواد: ${error.message}`);
  }
});

// 🧪 10. دالة اختبار إشعارات الغياب (للتطوير فقط)
export const testAbsenceNotification = onCall(async (request) => {
  // التحقق من أن المستدعي مسجل دخول
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "يجب تسجيل الدخول لاختبار الإشعارات");
  }

  const { studentUid, studentName, message, date } = request.data;

  try {
    // استخدام المستخدم الحالي إذا لم يتم تحديد studentUid
    const targetUid = studentUid || request.auth.uid;

    // جلب معلومات الطالب
    const studentDoc = await db.collection("users").doc(targetUid).get();
    if (!studentDoc.exists) {
      throw new HttpsError("not-found", "الطالب غير موجود");
    }

    const studentData = studentDoc.data();

    // ✅ استخدام Topics بدلاً من FCM Token
    const topic = `student_${targetUid}`;

    // إرسال إشعار تجريبي للغياب
    const testMessage = {
      notification: {
        title: `🧪 اختبار: ⚠️ تنبيه غياب - ${date || "اليوم"}`,
        body: message || "هذا إشعار تجريبي للغياب - اختبار الصوت والاهتزاز ✅",
      },
      data: {
        sound: "default",
        channel_id: "school_notifications_v2",
        priority: "high",
        click_action: "FLUTTER_NOTIFICATION_CLICK",
        notification_foreground: "true",
        type: "absence_test",
        student_name: studentName || studentData.name || "",
        date: date || new Date().toISOString().split('T')[0]
      },
      android: {
        priority: "high",
        notification: {
          sound: "default",
          channelId: "school_notifications_v2",
          priority: "high",
          defaultSound: true,
          defaultVibrateTimings: true
        },
      },
      apns: {
        payload: {
          aps: {
            sound: "default",
            badge: 1,
            contentAvailable: true
          },
        },
      },
      topic: topic, // ✅ إرسال للـ Topic مباشرة
    };

    await messaging.send(testMessage);

    console.log(`✅ Test absence notification sent to topic: ${topic}`);
    await logAction("test_absence_notify", {
      student: studentData.email,
      studentName: studentName,
      date: date,
      topic: topic,
    });

    return {
      success: true,
      message: `تم إرسال إشعار الاختبار للـ Topic: ${topic} 🎵📳`
    };

  } catch (error) {
    console.error("❌ Error sending test absence notification:", error);
    await logAction("error_test_absence_notify", { error: error.message });

    throw new HttpsError("internal", `فشل إرسال إشعار الاختبار: ${error.message}`);
  }
});
