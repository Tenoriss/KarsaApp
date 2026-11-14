import React, {
  useEffect,
  useRef,
  useState,
  useCallback,
  createContext,
  useContext,
} from "react";
import {
  SafeAreaView,
  View,
  Text,
  ScrollView,
  Pressable as NativePressable,
  TextInput,
  Image,
  StyleSheet,
  StatusBar,
  Platform,
  Switch,
  Animated,
  AccessibilityInfo,
  Modal,
  AppState,
} from "react-native";
import AsyncStorage from "@react-native-async-storage/async-storage";
import * as DocumentPicker from "expo-document-picker";
import * as FileSystem from "expo-file-system/legacy";
import * as Sharing from "expo-sharing";
import { Ionicons } from "@expo/vector-icons";
import { buildGradeReport } from "./gradeReports";
import {
  subjectInfo,
  subjects,
  quizBank as questionBank,
  practiceBank,
  subjectsForClass,
  normalizeSubject,
  religions,
  questionsFor,
  exercisesFor,
} from "./curriculum";

const lightColors = {
  ink: "#203e5a",
  muted: "#8294a3",
  rose: "#b1445d",
  pink: "#c8526d",
  line: "#efdfd9",
  bg: "#fffaf7",
  card: "#fffdfb",
  blue: "#6e9cc3",
};
// Older stored IPA entries are migrated to the full IPAS subject name on load.
const initialTasks = [
  {
    id: "seed5",
    subject: "Matematika",
    title: "Pecahan dan perbandingan",
    className: "Kelas 5",
    minutes: "30",
  },
  {
    id: "seed6",
    subject: "Ilmu Pengetahuan Alam dan Sosial (IPAS)",
    title: "Ekosistem dan lingkungan",
    className: "Kelas 6",
    minutes: "30",
  },
  {
    id: "t1",
    subject: "Matematika",
    title: "Penjumlahan sampai 20",
    className: "Kelas 1",
    minutes: "30",
  },
  {
    id: "t2",
    subject: "Bahasa Indonesia",
    title: "Membaca kalimat",
    className: "Kelas 1",
    minutes: "30",
  },
];
const practices = subjects.map((subject, i) => ({
  id:
    subject === "Matematika"
      ? "p1"
      : subject === "Bahasa Indonesia"
        ? "p2"
        : subject === "Ilmu Pengetahuan Alam dan Sosial (IPAS)"
          ? "p3"
          : `practice-${i}`,
  subject,
  title: `Latihan ${subject}`,
}));
const demoSeedTasks = (now) =>
  [5, 6].flatMap((grade) =>
    subjects.flatMap((subject, i) => {
      const due = new Date(now);
      due.setDate(due.getDate() + i + 1);
      due.setHours(23, 59, 59, 999);
      const past = new Date(now);
      past.setDate(past.getDate() - i - 2);
      past.setHours(23, 59, 59, 999);
      return [
        {
          id: `demo-${grade}-${i}-active`,
          subject,
          title: `Tugas ${subject}`,
          className: `Kelas ${grade}`,
          minutes: "30",
          dueAt: due.toISOString(),
          demo: true,
        },
        {
          id: `demo-${grade}-${i}-history`,
          subject,
          title: `Tugas sebelumnya · ${subject}`,
          className: `Kelas ${grade}`,
          minutes: "30",
          dueAt: past.toISOString(),
          demo: true,
          demoHistory: true,
        },
      ];
    }),
  );
const seedTasks = demoSeedTasks(new Date());
const demoResults = (tasks) =>
  Object.fromEntries(
    tasks
      .filter((t) => t.demoHistory)
      .map((t) => {
        const quiz = questionBank[t.subject];
        const answers = quiz.map((item, i) =>
          i < 7 ? item.answer : (item.answer + 1) % item.choices.length,
        );
        return [t.id, { score: 7, total: 10, answers, demo: true }];
      }),
  );
const initialAnnouncements = [
  {
    id: "a1",
    category: "KEGIATAN SEKOLAH",
    title: "Hari Literasi KARSA",
    detail: "Jumat, 6 November 2026 · Aula sekolah",
    body: "Mari tumbuhkan kebiasaan membaca melalui kegiatan berbagi cerita dan pojok baca kelas.",
    className: "Semua kelas",
  },
  {
    id: "a2",
    category: "UNTUK ORANG TUA",
    title: "Pertemuan Wali Murid",
    detail: "Sabtu, 7 November 2026 · 09.00 WIB",
    body: "Pertemuan rutin membahas perkembangan belajar dan kegiatan semester.",
    className: "Semua kelas",
  },
  {
    id: "a3",
    category: "PENGINGAT",
    title: "Pengumpulan tugas mingguan",
    detail: "",
    body: "Pastikan semua tugas dikumpulkan tepat waktu.",
    className: "Semua kelas",
  },
];
const defaults = {
  tasks: [...initialTasks, ...seedTasks],
  customPractices: [],
  results: demoResults(seedTasks),
  practiceDone: {},
  announcements: initialAnnouncements,
  readAnnouncements: [],
  teacherName: "Ibu Sari",
  waliName: "Ibu Sari",
  studentName: "Dimas Nugroho",
  notifications: true,
  reviewed: [],
  childClass: "Kelas 1",
  parentClass: "Kelas 1",
  studentClass: "Kelas 5",
  teacherSubject: "Matematika",
  religion: "",
  mood: null,
  darkMode: false,
  attendance: {},
  classScores: {},
  classEvents: [],
  materials: [],
  localNotifications: [],
  readNotifications: {},
};
const CLASSES = Array.from({ length: 6 }, (_, i) => `Kelas ${i + 1}`);
const WALI_CLASS = "Kelas 1";
const formatDateKey = (d) =>
  `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
const PARENT_CLASSES = CLASSES.slice(0, 4),
  STUDENT_CLASSES = CLASSES.slice(4);
const ACCOUNTS = {
  siswa: { id: "10050001", password: "siswa123", label: "Siswa kelas 5–6" },
  wali: { id: "19870001", password: "wali123", label: "Wali kelas" },
  guru: { id: "19870002", password: "guru123", label: "Guru mata pelajaran" },
  orangtua: { id: "10010001", password: "ortu123", label: "Orang tua / wali" },
};
const STORE = "@karsa-demo-v1";
// Soft outer depth plus an inset highlight gives surfaces a tactile clay finish.
const C = lightColors;
const clay = {
  soft: {
    borderWidth: 2,
    borderColor: "rgba(255,255,255,0.88)",
    shadowColor: "#b99da3",
    shadowOffset: { width: 0, height: 6 },
    shadowOpacity: 0.17,
    shadowRadius: 10,
    elevation: 3,
    ...Platform.select({
      web: {
        boxShadow:
          "0 7px 16px rgba(129,94,104,0.12), inset 0 2px 3px rgba(255,255,255,0.92), inset 0 -3px 6px rgba(184,151,158,0.08)",
      },
      default: {},
    }),
  },
  raised: {
    borderWidth: 2,
    borderColor: "rgba(255,255,255,0.55)",
    shadowColor: "#a77e88",
    shadowOffset: { width: 0, height: 7 },
    shadowOpacity: 0.24,
    shadowRadius: 9,
    elevation: 5,
    ...Platform.select({
      web: {
        boxShadow:
          "0 8px 16px rgba(155,91,105,0.23), inset 0 3px 3px rgba(255,255,255,0.28), inset 0 -4px 5px rgba(104,48,64,0.12)",
      },
      default: {},
    }),
  },
  inset: {
    borderWidth: 2,
    borderColor: "#f1e5e2",
    ...Platform.select({
      web: {
        boxShadow:
          "inset 0 3px 7px rgba(120,90,98,0.08), 0 2px 3px rgba(255,255,255,0.9)",
      },
      default: {},
    }),
  },
};
const MotionContext = createContext(false);
const ThemeContext = createContext(null);
const darkColors = {
  ink: "#f3eaf0",
  muted: "#bbc0ca",
  rose: "#f09ab0",
  pink: "#d56b85",
  line: "#4b4049",
  bg: "#211d27",
  card: "#302832",
  blue: "#85b2d1",
};
const MotionPressable = Animated.createAnimatedComponent(NativePressable);
function Pressable({
  children,
  style,
  onPress,
  onPressIn,
  onPressOut,
  disabled,
  ...props
}) {
  const reduce = useContext(MotionContext);
  const scale = useRef(new Animated.Value(1)).current;
  useEffect(() => {
    if (reduce) {
      scale.stopAnimation();
      scale.setValue(1);
    }
  }, [reduce, scale]);
  const animate = (toValue) => {
    if (reduce || !onPress || disabled) return;
    Animated.spring(scale, {
      toValue,
      useNativeDriver: Platform.OS !== "web",
      speed: 24,
      bounciness: 2,
    }).start();
  };
  return (
    <MotionPressable
      {...props}
      disabled={disabled}
      onPress={onPress}
      onPressIn={(e) => {
        animate(0.965);
        onPressIn?.(e);
      }}
      onPressOut={(e) => {
        animate(1);
        onPressOut?.(e);
      }}
      style={[style, { transform: [{ scale }] }]}
    >
      {children}
    </MotionPressable>
  );
}
function MotionSection({ children }) {
  return <View style={{ flexGrow: 1 }}>{children}</View>;
}
function PopIcon({ children }) {
  return <View>{children}</View>;
}
function ClaySection({ children, style }) {
  return <View style={style}>{children}</View>;
}
function FloatArt({ children, style }) {
  return <View style={style}>{children}</View>;
}
function Icon({ name, size = 20, color }) {
  const { C } = useContext(ThemeContext);
  return (
    <PopIcon>
      <Ionicons name={name} size={size} color={color || C.ink} />
    </PopIcon>
  );
}
function SchoolIdentity({ compact = false }) {
  const { styles } = useContext(ThemeContext);
  return (
    <View
      style={[styles.schoolIdentity, compact && styles.schoolIdentityCompact]}
    >
      <View style={styles.schoolLogoFrame}>
        <Image
          source={require("./assets/logo-sd-karitas.png")}
          style={styles.schoolLogo}
          resizeMode="contain"
          accessibilityLabel="Logo SD Karitas Purwokerto"
        />
      </View>
      <View style={{ flex: 1 }}>
        <Text style={styles.schoolName}>SD KARITAS PURWOKERTO</Text>
        <Text style={styles.schoolCaption}>Karitas Sahabat Belajar</Text>
      </View>
    </View>
  );
}
function Header({ title, sub, back }) {
  const { styles, C } = useContext(ThemeContext);
  return (
    <View style={styles.pageHeader}>
      {back && (
        <Pressable
          accessibilityRole="button"
          accessibilityLabel="Kembali"
          onPress={back}
          style={styles.back}
        >
          <Icon name="chevron-back" />
        </Pressable>
      )}
      <View style={{ flex: 1 }}>
        <Text style={styles.title}>{title}</Text>
        {sub && <Text style={styles.muted}>{sub}</Text>}
      </View>
    </View>
  );
}
function Button({ title, onPress, disabled }) {
  const { styles, C } = useContext(ThemeContext);
  return (
    <Pressable
      accessibilityRole="button"
      disabled={disabled}
      onPress={onPress}
      style={[styles.button, disabled && { opacity: 0.45 }]}
    >
      <Text style={styles.buttonText}>{title}</Text>
    </Pressable>
  );
}
function Card({ children, onPress, style }) {
  const { styles, C } = useContext(ThemeContext);
  return (
    <Pressable
      accessibilityRole={onPress ? "button" : undefined}
      onPress={onPress}
      style={[styles.card, style]}
    >
      {children}
    </Pressable>
  );
}
function Item({ item, onPress, status }) {
  const { styles, C } = useContext(ThemeContext);
  return (
    <Card onPress={onPress} style={styles.item}>
      <View
        style={[styles.itemIcon, { backgroundColor: item.color || "#f8ebec" }]}
      >
        <PopIcon>
          <Text style={{ fontSize: 23 }}>{item.icon}</Text>
        </PopIcon>
      </View>
      <View style={{ flex: 1 }}>
        <Text style={styles.itemTitle}>{item.title}</Text>
        <Text style={styles.smallMuted}>{item.meta}</Text>
      </View>
      {status && <Text style={styles.badge}>{status}</Text>}
    </Card>
  );
}
function Stat({ icon, label, value, desc, color, onPress }) {
  const { styles, C } = useContext(ThemeContext);
  return (
    <Card onPress={onPress} style={styles.stat}>
      <View style={[styles.statIcon, { backgroundColor: color }]}>
        <Icon name={icon} color="white" size={19} />
      </View>
      <View style={{ flex: 1 }}>
        <Text style={styles.smallMuted}>{label}</Text>
        <Text style={styles.statNumber}>{value}</Text>
        <Text style={styles.smallMuted}>{desc}</Text>
      </View>
    </Card>
  );
}
function Tabs({ options, value, onChange }) {
  const { styles, C } = useContext(ThemeContext);
  return (
    <View style={styles.segment}>
      {options.map((x) => (
        <Pressable
          key={x}
          onPress={() => onChange(x)}
          style={[styles.segmentItem, value === x && styles.segmentActive]}
        >
          <Text style={[styles.segmentText, value === x && { color: C.rose }]}>
            {x}
          </Text>
        </Pressable>
      ))}
    </View>
  );
}
function Chips({ options, value, onChange }) {
  const { styles } = useContext(ThemeContext);
  return (
    <ScrollView
      horizontal
      showsHorizontalScrollIndicator={false}
      style={{ flexGrow: 0, flexShrink: 0, marginBottom: 8 }}
      contentContainerStyle={{ alignItems: "center", paddingVertical: 4 }}
    >
      {options.map((x) => (
        <Pressable
          key={x}
          accessibilityRole="button"
          accessibilityState={{ selected: value === x }}
          onPress={() => onChange(x)}
          style={[
            styles.chip,
            { alignSelf: "center" },
            value === x && styles.chipActive,
          ]}
        >
          <Text style={[styles.chipText, value === x && { color: "white" }]}>
            {x}
          </Text>
        </Pressable>
      ))}
    </ScrollView>
  );
}
function SplashScreen({ ready, onFinish }) {
  const { styles, C } = useContext(ThemeContext);
  useEffect(() => {
    if (!ready) return;
    const timer = setTimeout(onFinish, 2300);
    return () => clearTimeout(timer);
  }, [ready, onFinish]);
  return (
    <View
      style={styles.splashStage}
      accessibilityLabel="KARSA, Karitas Sahabat Belajar. Memuat aplikasi."
    >
      <View style={styles.splashIllustration}>
        <Image
          source={require("./assets/splash-art.png")}
          style={styles.splashImage}
          resizeMode="contain"
        />
      </View>
      <View style={styles.loadingArea} accessibilityRole="progressbar">
        <View style={styles.loadingDots}>
          {[0, 1, 2].map((i) => (
            <View key={i} style={styles.loadingDot} />
          ))}
        </View>
        <Text style={styles.loadingText}>Menyiapkan pengalaman belajar</Text>
      </View>
    </View>
  );
}
function App() {
  const [data, setData] = useState(defaults),
    [loaded, setLoaded] = useState(false),
    [screen, setScreen] = useState("splash"),
    [role, setRole] = useState(null),
    [tab, setTab] = useState("Beranda"),
    [filter, setFilter] = useState("Semua kelas"),
    [taskFilter, setTaskFilter] = useState("Semua"),
    [selected, setSelected] = useState(null),
    [returnScreen, setReturnScreen] = useState("main"),
    [q, setQ] = useState(0),
    [choice, setChoice] = useState(null),
    [checked, setChecked] = useState(false),
    [answers, setAnswers] = useState([]),
    [essay, setEssay] = useState(""),
    [showExample, setShowExample] = useState(false),
    [month, setMonth] = useState(new Date().getMonth()),
    [year, setYear] = useState(new Date().getFullYear()),
    [day, setDay] = useState(new Date().getDate()),
    [username, setUsername] = useState(""),
    [password, setPassword] = useState(""),
    [draftTitle, setDraftTitle] = useState(""),
    [draftBody, setDraftBody] = useState(""),
    [draftSubject, setDraftSubject] = useState("Matematika"),
    [draftClass, setDraftClass] = useState("Kelas 1"),
    [draftMinutes, setDraftMinutes] = useState("30"),
    [error, setError] = useState(""),
    [setting, setSetting] = useState(""),
    [subjectTab, setSubjectTab] = useState("Tugas"),
    [search, setSearch] = useState(""),
    [showPassword, setShowPassword] = useState(false),
    [reduceMotion, setReduceMotion] = useState(false),
    [tipIndex, setTipIndex] = useState(0),
    [attachment, setAttachment] = useState(null),
    [sourceText, setSourceText] = useState(""),
    [summaryText, setSummaryText] = useState(""),
    [notice, setNotice] = useState(""),
    [storageError, setStorageError] = useState(false),
    [recapTab, setRecapTab] = useState("Kehadiran"),
    [recapDate, setRecapDate] = useState(() => formatDateKey(new Date())),
    [memberId, setMemberId] = useState(null),
    [scoreDraft, setScoreDraft] = useState(""),
    [eventDate, setEventDate] = useState(""),
    [draftDue, setDraftDue] = useState(""),
    [subjectFilter, setSubjectFilter] = useState("Semua"),
    [learnerSubjectTab, setLearnerSubjectTab] = useState("Tugas"),
    [now, setNow] = useState(Date.now()),
    [gradeClass, setGradeClass] = useState("Kelas 1"),
    [gradeReturn, setGradeReturn] = useState("main"),
    [exporting, setExporting] = useState(false);
  useEffect(() => {
    const timer = setInterval(() => setNow(Date.now()), 60000);
    const subscription = AppState.addEventListener("change", (state) => {
      if (state === "active") setNow(Date.now());
    });
    return () => {
      clearInterval(timer);
      subscription.remove();
    };
  }, []);
  const themeDark = !!data.darkMode;
  const C = themeDark ? darkColors : lightColors;
  const styles = themeDark ? darkStyles : lightStyles;
  useEffect(() => {
    let alive = true;
    AsyncStorage.getItem(STORE)
      .then((raw) => {
        if (alive && raw) {
          try {
            const saved = JSON.parse(raw);
            const savedTasks = (
              Array.isArray(saved.tasks) ? saved.tasks : []
            ).map((t) => ({ ...t, subject: normalizeSubject(t.subject) }));
            const missing = [...initialTasks, ...seedTasks].filter(
              (t) => !savedTasks.some((old) => old.id === t.id),
            );
            const addedResults = demoResults(missing);
            setData({
              ...defaults,
              ...saved,
              teacherSubject: normalizeSubject(
                saved.teacherSubject || defaults.teacherSubject,
              ),
              customPractices: (saved.customPractices || []).map((p) => ({
                ...p,
                subject: normalizeSubject(p.subject),
              })),
              materials: (saved.materials || []).map((m) => ({
                ...m,
                subject: normalizeSubject(m.subject),
              })),
              localNotifications: (saved.localNotifications || []).map((n) => ({
                ...n,
                subject: normalizeSubject(n.subject),
              })),
              results: { ...addedResults, ...(saved.results || {}) },
              tasks: [...savedTasks, ...missing],
            });
          } catch {}
        }
      })
      .catch(() => {})
      .finally(() => {
        if (alive) setLoaded(true);
      });
    return () => {
      alive = false;
    };
  }, []);
  useEffect(() => {
    if (loaded)
      AsyncStorage.setItem(STORE, JSON.stringify(data))
        .then(() => setStorageError(false))
        .catch(() => setStorageError(true));
  }, [data, loaded]);
  useEffect(() => {
    let active = true;
    AccessibilityInfo.isReduceMotionEnabled()
      .then((v) => {
        if (active) setReduceMotion(v);
      })
      .catch(() => {});
    const listener = AccessibilityInfo.addEventListener(
      "reduceMotionChanged",
      setReduceMotion,
    );
    return () => {
      active = false;
      listener?.remove();
    };
  }, []);
  const finishSplash = useCallback(() => setScreen("welcome"), []);
  const update = (patch) => setData((d) => ({ ...d, ...patch }));
  const teacher = role === "guru" || role === "wali";
  const wali = role === "wali";
  const student = role === "siswa";
  const allPractices = [...practices, ...(data.customPractices || [])];
  const visiblePractices = allPractices.filter(
    (p) =>
      (!p.className || p.className === data.childClass) &&
      subjectsForClass(data.childClass).includes(p.subject),
  );
  const doneCount = visiblePractices.filter(
    (p) => data.practiceDone[p.id],
  ).length;
  const activeTasks = data.tasks.filter(
    (t) =>
      t.className === data.childClass &&
      subjectsForClass(data.childClass).includes(t.subject) &&
      !data.results[t.id],
  );
  const visibleAnnouncements = data.announcements.filter((a) =>
    role === "wali"
      ? a.className === "Semua kelas" || a.className === WALI_CLASS
      : teacher ||
        a.className === "Semua kelas" ||
        a.className === data.childClass,
  );
  const unread = visibleAnnouncements.filter(
    (a) => !data.readAnnouncements.includes(a.id),
  ).length;
  const relevantNotifications = (data.localNotifications || []).filter((n) =>
    teacher
      ? n.target === "teachers" &&
        (role !== "guru" || n.subject === data.teacherSubject) &&
        (role !== "wali" || n.className === WALI_CLASS)
      : n.target === "learners" && n.className === data.childClass,
  );
  const notificationKey = teacher ? role : `${role}:${data.childClass}`;
  const unreadEvents = relevantNotifications.filter(
    (n) =>
      !((data.readNotifications || {})[notificationKey] || []).includes(n.id),
  ).length;
  const educatorTasks = data.tasks.filter(
    (t) =>
      (role !== "wali" || t.className === WALI_CLASS) &&
      (filter === "Semua kelas" || t.className === filter) &&
      (role !== "guru" || t.subject === data.teacherSubject),
  );
  const changeTab = (t) => {
    setTab(t);
    if (t === "Tugas") {
      setSubjectFilter("Semua");
      setLearnerSubjectTab("Tugas");
    }
    setTaskFilter(teacher ? "Semua" : "Aktif");
    setScreen("main");
  };
  const openTask = (t) => {
    setSelected(t);
    setScreen(teacher ? "teacherTask" : "taskDetail");
  };
  const startQuiz = () => {
    setQ(0);
    setChoice(null);
    setChecked(false);
    setAnswers([]);
    setScreen("quiz");
  };
  const selectedSubject = normalizeSubject(selected?.subject);
  const resultReligion =
    screen === "result" ? data.results[selected?.id]?.religion : undefined;
  const bank = questionsFor(
    selectedSubject,
    resultReligion === undefined ? data.religion : resultReligion,
  );
  const essayBank = exercisesFor(selectedSubject, data.religion);
  const nextQuiz = () => {
    const next = [...answers, choice];
    setAnswers(next);
    if (q === bank.length - 1) {
      const score = next.filter((a, i) => a === bank[i].answer).length;
      update({
        results: {
          ...data.results,
          [selected.id]: {
            score,
            total: bank.length,
            answers: next,
            religion: data.religion || "",
            studentName: data.studentName,
            className: selected.className,
          },
        },
        reviewed: data.reviewed.filter((id) => id !== selected.id),
        localNotifications: pushNotice(
          notification(
            "teachers",
            selected.subject,
            selected.className,
            `${data.studentName} menyelesaikan tugas ${selected.title}`,
            "task",
            selected.id,
          ),
        ),
      });
      setScreen("result");
    } else {
      setQ(q + 1);
      setChoice(null);
      setChecked(false);
    }
  };
  const practiceStart = () => {
    if (!teacher) setReturnScreen("main");
    setQ(0);
    setEssay("");
    setShowExample(false);
    setScreen("essay");
  };
  const nextEssay = () => {
    if (q === essayBank.length - 1) {
      if (!teacher)
        update({
          practiceDone: { ...data.practiceDone, [selected.id]: true },
          localNotifications: pushNotice(
            notification(
              "teachers",
              selected.subject,
              data.childClass,
              `${data.studentName} menyelesaikan latihan ${selected.title}`,
              "practice",
              selected.id,
            ),
          ),
        });
      setScreen("practiceResult");
    } else {
      setQ(q + 1);
      setEssay("");
      setShowExample(false);
    }
  };
  const openAnnouncement = (a) => {
    setSelected(a);
    update({
      readAnnouncements: [...new Set([...data.readAnnouncements, a.id])],
    });
    setScreen("announcementDetail");
  };
  const openForm = (kind) => {
    setDraftTitle("");
    setDraftBody("");
    setDraftSubject(role === "guru" ? data.teacherSubject : "Matematika");
    setDraftClass(
      role === "wali"
        ? WALI_CLASS
        : role === "guru" &&
            data.teacherSubject === "Ilmu Pengetahuan Alam dan Sosial (IPAS)" &&
            (filter === "Semua kelas" ||
              !subjectsForClass(filter).includes(data.teacherSubject))
          ? "Kelas 3"
          : filter === "Semua kelas"
            ? "Kelas 1"
            : filter,
    );
    setDraftMinutes("30");
    setDraftDue(formatDateKey(new Date(Date.now() + 7 * 86400000)));
    setError("");
    setNotice("");
    setAttachment(null);
    setSourceText("");
    setSummaryText("");
    setScreen(kind);
  };
  const notification = (
    target,
    subject,
    className,
    title,
    kind,
    contentId,
  ) => ({
    id: `n${Date.now()}-${Math.random().toString(36).slice(2, 7)}`,
    target,
    subject,
    className,
    title,
    kind,
    contentId,
    createdAt: new Date().toISOString(),
  });
  const pushNotice = (n) => [n, ...(data.localNotifications || [])];
  const pickAttachment = async () => {
    try {
      setError("");
      setNotice("");
      const result = await DocumentPicker.getDocumentAsync({
        type: [
          "application/pdf",
          "text/plain",
          "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
          "image/jpeg",
          "image/png",
        ],
        copyToCacheDirectory: true,
        multiple: false,
      });
      if (result.canceled) return;
      const f = result.assets[0],
        max = Platform.OS === "web" ? 1024 * 1024 : 10 * 1024 * 1024;
      if (f.size && f.size > max) {
        setError(
          `File terlalu besar. Batas ${Platform.OS === "web" ? "1" : "10"} MB per file.`,
        );
        return;
      }
      const isText =
        f.mimeType === "text/plain" || f.name.toLowerCase().endsWith(".txt");
      let uri = f.uri,
        text = "";
      if (Platform.OS === "web") {
        if (!f.file) throw new Error("Browser tidak menyediakan data file.");
        const total = JSON.stringify(data).length;
        if (total + (f.size || 0) * 1.4 > 2.5 * 1024 * 1024) {
          setError(
            "Penyimpanan demo browser hampir penuh. Gunakan file lebih kecil.",
          );
          return;
        }
        uri = await new Promise((resolve, reject) => {
          const reader = new FileReader();
          reader.onload = () => resolve(reader.result);
          reader.onerror = () => reject(new Error("Gagal membaca file."));
          reader.readAsDataURL(f.file);
        });
        if (isText) text = await f.file.text();
      } else {
        const dest =
          FileSystem.documentDirectory +
          `karsa-${Date.now()}-${f.name.replace(/[^a-zA-Z0-9._-]/g, "_")}`;
        await FileSystem.copyAsync({ from: f.uri, to: dest });
        uri = dest;
        if (isText) text = await FileSystem.readAsStringAsync(dest);
      }
      setAttachment({
        name: f.name,
        mimeType: f.mimeType || "application/octet-stream",
        uri,
        size: f.size || 0,
      });
      if (isText) setSourceText(text.slice(0, 12000));
      setNotice(
        isText
          ? "File teks berhasil dibaca."
          : "File terlampir. Untuk ringkasan, tempel teks materi secara manual.",
      );
    } catch (e) {
      setError("Gagal memilih file: " + (e.message || "coba lagi."));
    }
  };
  const openAttachment = async (file) => {
    if (!file) {
      setError("Tidak ada file terlampir.");
      return;
    }
    try {
      if (Platform.OS === "web") {
        const link = document.createElement("a");
        link.href = file.uri;
        link.download = file.name;
        link.click();
      } else if (await Sharing.isAvailableAsync()) {
        await Sharing.shareAsync(file.uri, {
          mimeType: file.mimeType,
          dialogTitle: "Buka atau bagikan " + file.name,
        });
      } else setError("Perangkat ini tidak mendukung membuka file.");
    } catch (e) {
      setError("Tidak dapat membuka file: " + (e.message || "coba lagi."));
    }
  };
  const summarizeOffline = () => {
    const cleaned = sourceText.trim().replace(/\s+/g, " ");
    if (!cleaned) {
      setError(
        "Tempel teks materi atau unggah file .txt untuk diringkas. PDF belum dapat dibaca otomatis di demo.",
      );
      return;
    }
    const sentences = cleaned.match(/[^.!?]+[.!?]?/g) || [cleaned];
    setSummaryText(
      sentences
        .slice(0, 3)
        .map((x) => x.trim())
        .filter(Boolean)
        .join(" ")
        .slice(0, 1200),
    );
    setError("");
    setNotice("Ringkasan dipilih dari tiga kalimat pertama; ini bukan AI.");
  };
  const markNotification = (n) => {
    const read = data.readNotifications || {};
    update({
      readNotifications: {
        ...read,
        [notificationKey]: [
          ...new Set([...(read[notificationKey] || []), n.id]),
        ],
      },
    });
    if (wali && n.kind === "task") {
      setTab("Rekap");
      setScreen("main");
      return;
    }
    if (n.kind === "agenda") {
      const event = (data.classEvents || []).find((e) => e.id === n.contentId);
      if (event) {
        setSelected(event);
        setScreen("agendaDetail");
        return;
      }
    }
    if (n.kind === "task") {
      const item = data.tasks.find((t) => t.id === n.contentId);
      if (item) {
        setTab("Tugas");
        setSelected(item);
        setScreen(teacher ? "teacherTask" : "taskDetail");
        return;
      }
    }
    if (n.kind === "material") {
      const item = (data.materials || []).find((m) => m.id === n.contentId);
      if (item) {
        setSelected(item);
        setScreen("materialDetail");
        return;
      }
    }
    setNotice(n.title);
    setScreen("notifications");
  };
  const saveMaterial = () => {
    if (!subjectsForClass(draftClass).includes(draftSubject)) {
      setError("IPAS hanya untuk kelas 3–6.");
      return;
    }
    if (!draftTitle.trim() || (!attachment && !summaryText.trim())) {
      setError("Isi judul dan lampirkan file atau isi ringkasan materi.");
      return;
    }
    const id = `m${Date.now()}`,
      m = {
        id,
        title: draftTitle.trim(),
        subject: draftSubject,
        className: draftClass,
        file: attachment,
        summary: summaryText.trim(),
        teacher: data.teacherName,
      };
    update({
      materials: [m, ...(data.materials || [])],
      localNotifications: pushNotice(
        notification(
          "learners",
          m.subject,
          m.className,
          `${data.teacherName} menambah ringkasan materi: ${m.title}`,
          "material",
          id,
        ),
      ),
    });
    setNotice("Materi tersimpan di perangkat ini.");
    setScreen("materials");
  };
  const submitFileTask = () => {
    const n = notification(
      "teachers",
      selected.subject,
      selected.className,
      `${data.studentName} menandai tugas ${selected.title} selesai`,
      "task",
      selected.id,
    );
    update({
      results: {
        ...data.results,
        [selected.id]: {
          submittedOnly: true,
          studentName: data.studentName,
          className: selected.className,
        },
      },
      reviewed: data.reviewed.filter((id) => id !== selected.id),
      localNotifications: pushNotice(n),
    });
    setNotice(
      "Tugas ditandai selesai di perangkat ini. Tidak ada file jawaban yang dikirim.",
    );
    setTaskFilter("Riwayat");
    setTab("Tugas");
    setScreen("main");
  };
  const deadlineLabel = (t) => {
    if (!t.dueAt) return "Belum ada tenggat";
    const diff = new Date(t.dueAt).getTime() - now;
    if (!Number.isFinite(diff)) return "Tenggat tidak valid";
    if (diff <= 0) return "Tenggat terlewat";
    const days = Math.floor(diff / 86400000),
      hours = Math.floor((diff % 86400000) / 3600000);
    return days
      ? `${days} hari ${hours} jam lagi`
      : `${Math.max(1, hours)} jam lagi`;
  };
  const formatDue = (t) =>
    t.dueAt
      ? new Date(t.dueAt).toLocaleString("id-ID", {
          day: "numeric",
          month: "short",
          year: "numeric",
          hour: "2-digit",
          minute: "2-digit",
        })
      : "Belum diatur";
  const parseDue = (raw) => {
    const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(raw.trim());
    if (!match) return null;
    const d = new Date(
      Number(match[1]),
      Number(match[2]) - 1,
      Number(match[3]),
      23,
      59,
      59,
      999,
    );
    return formatDateKey(d) === raw.trim() ? d : null;
  };
  const saveTask = () => {
    if (
      !draftTitle.trim() ||
      !Number.isFinite(Number(draftMinutes)) ||
      Number(draftMinutes) <= 0
    ) {
      setError("Isi judul dan batas waktu yang valid.");
      return;
    }
    if (!attachment && !draftBody) {
      setError("Lampirkan file tugas atau pilih buat kuis contoh.");
      return;
    }
    const due = parseDue(draftDue);
    if (!due || due.getTime() <= Date.now()) {
      setError("Isi tanggal tenggat yang valid dan belum lewat (YYYY-MM-DD).");
      return;
    }
    if (!subjectsForClass(draftClass).includes(draftSubject)) {
      setError("IPAS hanya untuk kelas 3–6.");
      return;
    }
    const id = `t${Date.now()}`,
      task = {
        id,
        subject: draftSubject,
        title: draftTitle.trim(),
        className: draftClass,
        minutes: draftMinutes,
        kind: attachment ? "file" : "quiz",
        file: attachment,
        teacher: data.teacherName,
        dueAt: due.toISOString(),
      };
    update({
      tasks: [...data.tasks, task],
      localNotifications: pushNotice(
        notification(
          "learners",
          task.subject,
          task.className,
          `${data.teacherName} menambahkan tugas baru: ${task.title}`,
          "task",
          id,
        ),
      ),
    });
    setNotice("Tugas tersimpan di perangkat ini.");
    changeTab("Tugas");
  };
  const saveAnnouncement = () => {
    if (!draftTitle.trim() || !draftBody.trim()) {
      setError("Isi judul dan isi pengumuman.");
      return;
    }
    update({
      announcements: [
        {
          id: `a${Date.now()}`,
          title: draftTitle.trim(),
          body: draftBody.trim(),
          detail: "Baru saja · " + draftClass,
          category: "PENGUMUMAN GURU",
          className: draftClass,
        },
        ...data.announcements,
      ],
    });
    setScreen("announcements");
  };
  const taskItem = (t) => ({
    ...subjectInfo[t.subject],
    title: t.title,
    meta: `${t.subject} · ${t.className} · ${t.minutes} menit${t.demo ? " · contoh" : ""} · ${deadlineLabel(t)}`,
  });
  const practiceItem = (p) => ({
    ...subjectInfo[p.subject],
    title: p.title,
    meta: "5 soal esai · tanpa batas waktu",
  });
  const classMembers = [
    { id: "dimas", name: data.studentName, icon: "👦🏻" },
    { id: "sari", name: "Sari Putri", icon: "👧🏻" },
    { id: "rafi", name: "Rafi Pratama", icon: "👦🏻" },
  ];
  // Demo has only one locally simulated learner profile, not a real class roster.
  const gradeRoster = (className, task) => {
    const result = task ? data.results[task.id] : null;
    const exampleNames = {
      "Kelas 1": ["Dimas Nugroho", "Sari Putri", "Rafi Pratama"],
      "Kelas 2": ["Alya Putri", "Bima Saputra", "Nadia Lestari"],
      "Kelas 3": ["Raka Pratama", "Citra Maharani", "Fajar Ramadhan"],
      "Kelas 4": ["Nabila Putri", "Rizky Saputra", "Intan Sari"],
      "Kelas 5": ["Dimas Nugroho", "Nisa Aulia", "Bintang Pratama"],
      "Kelas 6": ["Adit Prasetyo", "Dewi Lestari", "Farhan Maulana"],
    }[className] || ["Siswa A", "Siswa B", "Siswa C"];
    const activeProfile =
      className === data.childClass ||
      className === data.studentClass ||
      className === data.parentClass;
    const profileName =
      result?.studentName ||
      (result && !result.demo ? "Profil siswa (data lama)" : null) ||
      (activeProfile ? data.studentName : exampleNames[0]);
    return [
      {
        id: "profile",
        name: profileName,
        profile: true,
        example: !result?.studentName && !activeProfile,
      },
      { id: "example-b", name: exampleNames[1], profile: false, example: true },
      { id: "example-c", name: exampleNames[2], profile: false, example: true },
    ];
  };
  const gradeFor = (task, member) => {
    const r = member.profile ? data.results[task.id] : null;
    if (
      !r ||
      r.submittedOnly ||
      !Number.isFinite(r.score) ||
      !Number.isFinite(r.total) ||
      r.total <= 0
    )
      return null;
    return Math.round((r.score / r.total) * 10000) / 100;
  };
  const gradeNote = (task, member) => {
    const r = member.profile ? data.results[task.id] : null;
    if (!r) return "Belum ada nilai";
    if (r.submittedOnly) return "File ditandai selesai; belum dinilai";
    return r.demo
      ? "Nilai contoh"
      : r.studentName
        ? "Hasil lokal"
        : "Hasil lokal lama; identitas belum tercatat";
  };
  const reportRows = (className) =>
    data.tasks
      .filter(
        (t) => t.className === className && t.subject === data.teacherSubject,
      )
      .flatMap((task) =>
        gradeRoster(className, task).map((member) => ({
          name: member.name,
          task: task.title,
          grade: gradeFor(task, member),
          note:
            gradeNote(task, member) + (member.example ? " · siswa contoh" : ""),
        })),
      );
  const openGradeRecap = (className, from) => {
    setGradeClass(className || "Kelas 1");
    setGradeReturn(from);
    setError("");
    setNotice("");
    setScreen("gradeRecap");
  };
  const exportGrades = async (format) => {
    if (exporting) return;
    setExporting(true);
    setError("");
    setNotice("");
    try {
      const rows = reportRows(gradeClass);
      const base64 = await buildGradeReport(format, {
        className: gradeClass,
        subject: data.teacherSubject,
        teacher: data.teacherName,
        rows,
      });
      const ext = format === "Excel" ? "xlsx" : "pdf",
        mime =
          format === "Excel"
            ? "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
            : "application/pdf",
        name = `KARSA-Rekap-${gradeClass.replace(/\s+/g, "-")}-${data.teacherSubject
          .replace(/[^a-zA-Z0-9]+/g, "-")
          .replace(/-+$/, "")
          .slice(0, 45)}.${ext}`;
      if (Platform.OS === "web") {
        const bytes = Uint8Array.from(atob(base64), (c) => c.charCodeAt(0));
        const url = URL.createObjectURL(new Blob([bytes], { type: mime }));
        const link = document.createElement("a");
        link.href = url;
        link.download = name;
        document.body.appendChild(link);
        link.click();
        link.remove();
        setTimeout(() => URL.revokeObjectURL(url), 60000);
        setNotice(
          "File diunduh. Bagikan secara manual kepada wali kelas yang sesuai.",
        );
      } else {
        const uri = FileSystem.cacheDirectory + name;
        await FileSystem.writeAsStringAsync(uri, base64, {
          encoding: FileSystem.EncodingType.Base64,
        });
        if (await Sharing.isAvailableAsync()) {
          await Sharing.shareAsync(uri, {
            mimeType: mime,
            dialogTitle: `Bagikan rekap ${gradeClass}`,
            UTI:
              format === "PDF"
                ? "com.adobe.pdf"
                : "org.openxmlformats.spreadsheetml.sheet",
          });
          setNotice(
            "Pilih penerima di menu berbagi perangkat. Aplikasi tidak mengirim otomatis.",
          );
        } else {
          setError("Menu berbagi tidak tersedia di perangkat ini.");
        }
      }
    } catch (e) {
      setError(`Gagal membuat rekap: ${e.message || "coba lagi"}`);
    } finally {
      setExporting(false);
    }
  };
  const todayKey = formatDateKey(new Date());
  const dayAttendance = (data.attendance || {})[recapDate] || {};
  const todayAttendance = (data.attendance || {})[todayKey] || {};
  const recordsFor = (status) =>
    classMembers.filter((m) => todayAttendance[m.id] === status).length;
  const classScores = data.classScores || {};
  const scoredMembers = classMembers.filter(
    (m) => typeof classScores[m.id] === "number",
  );
  const scoreAverage = scoredMembers.length
    ? Math.round(
        scoredMembers.reduce((sum, m) => sum + classScores[m.id], 0) /
          scoredMembers.length,
      )
    : null;
  const editMember = (m) => {
    setMemberId(m.id);
    setScoreDraft(
      typeof classScores[m.id] === "number" ? String(classScores[m.id]) : "",
    );
    setError("");
    setScreen("waliMember");
  };
  const setAttendance = (id, status) =>
    update({
      attendance: {
        ...(data.attendance || {}),
        [recapDate]: { ...dayAttendance, [id]: status },
      },
    });
  const moveRecapDate = (amount) => {
    const [y, m, d] = recapDate.split("-").map(Number);
    setRecapDate(formatDateKey(new Date(y, m - 1, d + amount)));
  };
  const saveScore = () => {
    const raw = scoreDraft.trim();
    if (!raw || !/^\d+(\.\d+)?$/.test(raw) || Number(raw) > 100) {
      setError("Masukkan nilai antara 0 dan 100.");
      return;
    }
    update({ classScores: { ...classScores, [memberId]: Number(raw) } });
    setError("");
    setTab("Rekap");
    setRecapTab("Nilai");
    setScreen("main");
  };
  const openEventForm = () => {
    setDraftTitle("");
    setDraftBody("");
    setEventDate(formatDateKey(new Date(year, month, day)));
    setError("");
    setScreen("agendaForm");
  };
  const saveEvent = () => {
    const raw = eventDate.trim(),
      match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(raw);
    const date = match
      ? new Date(Number(match[1]), Number(match[2]) - 1, Number(match[3]))
      : null;
    if (!draftTitle.trim() || !date || formatDateKey(date) !== raw) {
      setError("Isi judul dan tanggal valid dengan format YYYY-MM-DD.");
      return;
    }
    const event = {
      id: `e${Date.now()}`,
      title: draftTitle.trim(),
      body: draftBody.trim(),
      date: raw,
      className: WALI_CLASS,
      teacher: data.waliName,
    };
    update({
      classEvents: [...(data.classEvents || []), event],
      localNotifications: pushNotice(
        notification(
          "learners",
          "Agenda",
          WALI_CLASS,
          `${data.waliName} menambahkan agenda: ${event.title}`,
          "agenda",
          event.id,
        ),
      ),
    });
    setYear(date.getFullYear());
    setMonth(date.getMonth());
    setDay(date.getDate());
    setTab("Agenda");
    setScreen("main");
  };
  const ChartRow = ({ label, count, total, color, display }) => (
    <View style={styles.chartRow}>
      <Text style={styles.chartLabel}>{label}</Text>
      <View style={styles.chartTrack}>
        <View
          style={[
            styles.chartFill,
            {
              width: `${total ? (count / total) * 100 : 0}%`,
              backgroundColor: color,
            },
          ]}
        />
      </View>
      <Text style={styles.chartNumber}>
        {display === undefined ? count : display}
      </Text>
    </View>
  );
  const waliHome = () => {
    const notRecorded =
      classMembers.length -
      classMembers.filter((m) => todayAttendance[m.id]).length;
    return (
      <>
        <SchoolIdentity compact />
        <View style={styles.greeting}>
          <View style={styles.avatar}>
            <Text style={{ fontSize: 24 }}>👩🏻‍🏫</Text>
          </View>
          <View style={{ flex: 1 }}>
            <Text style={styles.smallMuted}>Selamat datang, Wali Kelas</Text>
            <Text style={styles.name}>{data.waliName}</Text>
            <Text style={styles.smallMuted}>
              {WALI_CLASS} · SD Karitas Purwokerto
            </Text>
          </View>
          <Pressable
            accessibilityRole="button"
            accessibilityLabel={
              themeDark ? "Aktifkan mode terang" : "Aktifkan mode gelap"
            }
            onPress={() => update({ darkMode: !themeDark })}
            style={styles.bell}
          >
            <Icon
              name={themeDark ? "sunny-outline" : "moon-outline"}
              color={C.rose}
            />
          </Pressable>
          <Pressable
            accessibilityLabel="Pengumuman"
            onPress={() => setScreen("notifications")}
            style={styles.bell}
          >
            <Icon name="notifications-outline" color={C.rose} />
            {data.notifications && unread + unreadEvents > 0 && (
              <View style={styles.dot}>
                <Text style={styles.dotText}>{unread + unreadEvents}</Text>
              </View>
            )}
          </Pressable>
        </View>
        <ClaySection style={styles.waliHero}>
          <Text style={styles.overline}>RUANG WALI KELAS</Text>
          <Text style={styles.waliHeroTitle}>
            Tumbuh bersama, {WALI_CLASS} 🌱
          </Text>
          <Text style={styles.muted}>
            Pantau kehadiran dan perkembangan belajar siswa dalam satu tempat.
          </Text>
        </ClaySection>
        <View style={styles.stats}>
          <Stat
            icon="people"
            label="Anggota kelas"
            value={String(classMembers.length)}
            desc="Data contoh"
            color={C.blue}
            onPress={() => changeTab("Anggota")}
          />
          <Stat
            icon="checkmark-circle"
            label="Hadir hari ini"
            value={`${recordsFor("Hadir")}/${classMembers.length}`}
            desc={`${notRecorded} belum dicatat`}
            color={C.pink}
            onPress={() => {
              setRecapDate(todayKey);
              setRecapTab("Kehadiran");
              changeTab("Rekap");
            }}
          />
        </View>
        <View style={styles.sectionRow}>
          <Text style={styles.section}>Kehadiran hari ini</Text>
          <Pressable
            onPress={() => {
              setRecapDate(todayKey);
              setRecapTab("Kehadiran");
              changeTab("Rekap");
            }}
          >
            <Text style={styles.link}>Isi kehadiran ›</Text>
          </Pressable>
        </View>
        <Card>
          <Text style={styles.smallMuted}>
            {new Date().toLocaleDateString("id-ID", {
              weekday: "long",
              day: "numeric",
              month: "long",
              year: "numeric",
            })}{" "}
            · data dicatat manual
          </Text>
          {[
            ["Hadir", "#78b995"],
            ["Izin", "#79a6cd"],
            ["Sakit", "#c58aad"],
            ["Alpa", "#cd6c7d"],
          ].map(([label, color]) => (
            <ChartRow
              key={label}
              label={label}
              count={recordsFor(label)}
              total={classMembers.length}
              color={color}
            />
          ))}
          <Text style={styles.smallMuted}>
            {notRecorded} dari {classMembers.length} siswa belum dicatat.
          </Text>
        </Card>
        <View style={styles.sectionRow}>
          <Text style={styles.section}>Gambaran nilai</Text>
          <Pressable
            onPress={() => {
              setRecapTab("Nilai");
              changeTab("Rekap");
            }}
          >
            <Text style={styles.link}>Lihat rekap ›</Text>
          </Pressable>
        </View>
        <Card>
          <View style={styles.missionTop}>
            <View style={styles.statIcon}>
              <Text style={{ fontSize: 24 }}>📊</Text>
            </View>
            <View style={{ flex: 1 }}>
              <Text style={styles.itemTitle}>Rata-rata kelas</Text>
              <Text style={styles.smallMuted}>
                Dari {scoredMembers.length} siswa yang sudah diisi
              </Text>
            </View>
            <Text style={styles.statNumber}>
              {scoreAverage === null ? "—" : scoreAverage}
            </Text>
          </View>
          {!scoredMembers.length ? (
            <Text style={[styles.smallMuted, { marginTop: 10 }]}>
              Belum ada nilai. Isi rekap nilai untuk melihat grafik.
            </Text>
          ) : (
            scoredMembers.map((m) => (
              <ChartRow
                key={m.id}
                label={m.name.split(" ")[0]}
                count={classScores[m.id]}
                total={100}
                color={C.blue}
              />
            ))
          )}
        </Card>
        <Pressable
          style={styles.waliQuickLink}
          onPress={() => changeTab("Agenda")}
        >
          <Text style={styles.itemTitle}>📅 Agenda kelas</Text>
          <Text style={styles.link}>Lihat agenda ›</Text>
        </Pressable>
        <Text style={styles.loginNote}>
          Data contoh disimpan di perangkat ini, bukan data sekolah sebenarnya.
        </Text>
      </>
    );
  };
  const waliMembers = () => (
    <>
      <Header
        title="Anggota Kelas"
        sub={`${WALI_CLASS} · ${classMembers.length} siswa contoh`}
      />
      <Text style={styles.muted}>
        Ketuk nama siswa untuk melihat dan mengisi nilai ringkas.
      </Text>
      <View style={{ height: 12 }} />
      {classMembers.map((m) => (
        <Item
          key={m.id}
          item={{
            icon: m.icon,
            title: m.name,
            meta:
              typeof classScores[m.id] === "number"
                ? `Nilai ringkas ${classScores[m.id]} · data lokal`
                : "Nilai belum diisi",
            color: "#f8ebec",
          }}
          status={todayAttendance[m.id] || "Belum absen"}
          onPress={() => editMember(m)}
        />
      ))}
      <Button
        title="Isi kehadiran"
        onPress={() => {
          setRecapDate(todayKey);
          setRecapTab("Kehadiran");
          changeTab("Rekap");
        }}
      />
    </>
  );
  const waliRecap = () => (
    <>
      <Header title="Rekap Kelas" sub={`${WALI_CLASS} · data lokal`} />
      <Tabs
        options={["Kehadiran", "Nilai"]}
        value={recapTab}
        onChange={setRecapTab}
      />
      {recapTab === "Kehadiran" ? (
        <>
          <View style={styles.calendarHeader}>
            <Pressable
              accessibilityLabel="Tanggal sebelumnya"
              onPress={() => moveRecapDate(-1)}
            >
              <Icon name="chevron-back" />
            </Pressable>
            <Text style={styles.itemTitle}>
              {(() => {
                const [y, m, d] = recapDate.split("-").map(Number);
                return new Date(y, m - 1, d).toLocaleDateString("id-ID", {
                  day: "numeric",
                  month: "long",
                  year: "numeric",
                });
              })()}
            </Text>
            <Pressable
              accessibilityLabel="Tanggal berikutnya"
              onPress={() => moveRecapDate(1)}
            >
              <Icon name="chevron-forward" />
            </Pressable>
          </View>
          <Text style={[styles.muted, { marginBottom: 14 }]}>
            Pilih satu status untuk setiap siswa. Perubahan tersimpan otomatis.
          </Text>
          {classMembers.map((m) => (
            <Card key={m.id}>
              <View style={styles.missionTop}>
                <Text style={{ fontSize: 24 }}>{m.icon}</Text>
                <View style={{ flex: 1 }}>
                  <Text style={styles.itemTitle}>{m.name}</Text>
                  <Text style={styles.smallMuted}>
                    {dayAttendance[m.id] || "Belum dicatat"}
                  </Text>
                </View>
              </View>
              <View style={styles.attendanceOptions}>
                {["Hadir", "Izin", "Sakit", "Alpa"].map((status) => (
                  <Pressable
                    key={status}
                    accessibilityLabel={`${m.name}: ${status}`}
                    onPress={() => setAttendance(m.id, status)}
                    style={[
                      styles.attendanceChip,
                      dayAttendance[m.id] === status &&
                        styles.attendanceChipActive,
                    ]}
                  >
                    <Text
                      style={[
                        styles.attendanceText,
                        dayAttendance[m.id] === status && { color: "white" },
                      ]}
                    >
                      {status}
                    </Text>
                  </Pressable>
                ))}
              </View>
              {dayAttendance[m.id] && (
                <Pressable
                  accessibilityLabel={`Hapus kehadiran ${m.name}`}
                  onPress={() => {
                    const day = { ...dayAttendance };
                    delete day[m.id];
                    update({
                      attendance: {
                        ...(data.attendance || {}),
                        [recapDate]: day,
                      },
                    });
                  }}
                  style={{ alignSelf: "flex-end", paddingTop: 8 }}
                >
                  <Text style={styles.link}>Hapus catatan</Text>
                </Pressable>
              )}
            </Card>
          ))}
        </>
      ) : (
        <>
          <Card>
            <Text style={styles.itemTitle}>
              Rata-rata kelas: {scoreAverage === null ? "—" : scoreAverage}
            </Text>
            <Text style={styles.smallMuted}>
              Rata-rata dari {scoredMembers.length} nilai ringkas yang diisi
              manual, skala 0–100.
            </Text>
            {classMembers.map((m) => (
              <ChartRow
                key={m.id}
                label={m.name.split(" ")[0]}
                count={
                  typeof classScores[m.id] === "number" ? classScores[m.id] : 0
                }
                display={
                  typeof classScores[m.id] === "number"
                    ? String(classScores[m.id])
                    : "—"
                }
                total={100}
                color={C.pink}
              />
            ))}
          </Card>
          <Text style={[styles.muted, { marginBottom: 12 }]}>
            Ketuk siswa untuk menambah atau mengubah nilai.
          </Text>
          {classMembers.map((m) => (
            <Item
              key={m.id}
              item={{
                icon: m.icon,
                title: m.name,
                meta: "Nilai ringkas · data lokal",
                color: "#e4eef7",
              }}
              status={
                typeof classScores[m.id] === "number"
                  ? String(classScores[m.id])
                  : "Belum diisi"
              }
              onPress={() => editMember(m)}
            />
          ))}
        </>
      )}
    </>
  );
  const waliAgenda = () => {
    const date = new Date(year, month, 1),
      first = (date.getDay() + 6) % 7,
      days = new Date(year, month + 1, 0).getDate(),
      key = formatDateKey(new Date(year, month, day));
    const events = (data.classEvents || []).filter(
      (e) => e.className === WALI_CLASS && e.date === key,
    );
    const move = (n) => {
      const d = new Date(year, month + n, 1);
      setMonth(d.getMonth());
      setYear(d.getFullYear());
      setDay(1);
    };
    return (
      <>
        <Header
          title="Agenda Kelas"
          sub={`${WALI_CLASS} · kegiatan dan pengingat`}
        />
        <Button title="+ Tambah agenda" onPress={openEventForm} />
        <View style={[styles.calendarHeader, { marginTop: 20 }]}>
          <Pressable
            accessibilityLabel="Bulan sebelumnya"
            onPress={() => move(-1)}
          >
            <Icon name="chevron-back" />
          </Pressable>
          <Text style={styles.section}>
            {date.toLocaleDateString("id-ID", {
              month: "long",
              year: "numeric",
            })}
          </Text>
          <Pressable
            accessibilityLabel="Bulan berikutnya"
            onPress={() => move(1)}
          >
            <Icon name="chevron-forward" />
          </Pressable>
        </View>
        <View style={styles.grid}>
          {["Sen", "Sel", "Rab", "Kam", "Jum", "Sab", "Min"].map((x) => (
            <Text key={x} style={styles.dayLabel}>
              {x}
            </Text>
          ))}
          {Array.from({ length: first }, (_, i) => (
            <Text key={"b" + i} style={styles.day} />
          ))}
          {Array.from({ length: days }, (_, i) => (
            <Text
              onPress={() => setDay(i + 1)}
              key={i}
              style={[styles.day, day === i + 1 && styles.today]}
            >
              {i + 1}
            </Text>
          ))}
        </View>
        <Text style={styles.section}>
          Agenda · {day}{" "}
          {date.toLocaleDateString("id-ID", { month: "long", year: "numeric" })}
        </Text>
        {events.map((e) => (
          <Item
            key={e.id}
            item={{
              icon: "📅",
              title: e.title,
              meta: `${WALI_CLASS} · ${e.date}`,
              color: "#f8ebec",
            }}
            onPress={() => {
              setSelected(e);
              setScreen("agendaDetail");
            }}
            status="Lihat"
          />
        ))}
        {!events.length && (
          <Text style={styles.muted}>
            Belum ada agenda kelas pada tanggal ini.
          </Text>
        )}
        <Text style={styles.loginNote}>
          Agenda disimpan lokal. Notifikasi hanya terlihat di perangkat yang
          sama.
        </Text>
      </>
    );
  };
  const waliProfile = () => (
    <>
      <Header title="Profil Wali Kelas" sub="Senang bertemu denganmu!" />
      <ClaySection style={styles.profileHero}>
        <View style={styles.bigAvatar}>
          <Text style={{ fontSize: 42 }}>👩🏻‍🏫</Text>
        </View>
        <Text style={styles.name}>{data.waliName}</Text>
        <Text style={styles.muted}>
          Wali {WALI_CLASS} · SD Karitas Purwokerto
        </Text>
        <Text style={styles.profileBadge}>Wali kelas aktif</Text>
      </ClaySection>
      <Text style={styles.section}>Informasi Wali Kelas</Text>
      <Card>
        <Text style={styles.smallMuted}>Kelas diampu</Text>
        <Text style={styles.itemTitle}>{WALI_CLASS}</Text>
        <Text style={[styles.smallMuted, { marginTop: 10 }]}>NIP demo</Text>
        <Text style={styles.itemTitle}>{ACCOUNTS.wali.id}</Text>
      </Card>
      <Text style={styles.section}>Ringkasan Aktivitas</Text>
      <View style={styles.stats}>
        <Stat
          icon="people"
          label="Anggota"
          value={String(classMembers.length)}
          desc="Data contoh"
          color={C.blue}
          onPress={() => changeTab("Anggota")}
        />
        <Stat
          icon="checkmark-circle"
          label="Hadir hari ini"
          value={`${recordsFor("Hadir")}/${classMembers.length}`}
          desc="Rekap kehadiran"
          color={C.pink}
          onPress={() => {
            setRecapDate(todayKey);
            setRecapTab("Kehadiran");
            changeTab("Rekap");
          }}
        />
      </View>
      <Text style={[styles.section, { marginTop: 10 }]}>Pengaturan</Text>
      {[
        "Informasi pribadi",
        "Tampilan",
        "Notifikasi",
        "Privasi dan keamanan",
        "Pusat bantuan",
      ].map((x) => (
        <Card
          key={x}
          onPress={() => {
            setSetting(x);
            setDraftTitle(data.waliName);
            setError("");
            setScreen("setting");
          }}
          style={styles.setting}
        >
          <Icon
            name={
              x === "Informasi pribadi"
                ? "person-outline"
                : x === "Tampilan"
                  ? "moon-outline"
                  : x === "Notifikasi"
                    ? "notifications-outline"
                    : x === "Privasi dan keamanan"
                      ? "shield-checkmark-outline"
                      : "help-circle-outline"
            }
            color={C.rose}
          />
          <Text style={[styles.itemTitle, { flex: 1, marginLeft: 12 }]}>
            {x}
          </Text>
          <Icon name="chevron-forward" size={17} color={C.muted} />
        </Card>
      ))}
      <Pressable
        onPress={() => {
          setRole(null);
          setScreen("welcome");
          setUsername("");
          setPassword("");
        }}
        style={styles.logout}
      >
        <Text style={styles.link}>Keluar dari akun demo</Text>
      </Pressable>
    </>
  );
  const dashboard = () =>
    student ? (
      <>
        <SchoolIdentity compact />
        <View style={styles.greeting}>
          <View style={styles.avatar}>
            <Text style={{ fontSize: 24 }}>👦🏻</Text>
          </View>
          <View style={{ flex: 1 }}>
            <Text style={styles.smallMuted}>Halo, selamat belajar!</Text>
            <Text style={styles.name}>{data.studentName}</Text>
            <Text style={styles.smallMuted}>
              {data.childClass} · SD Karitas Purwokerto
            </Text>
          </View>
          <Pressable
            accessibilityRole="button"
            accessibilityLabel={
              themeDark ? "Aktifkan mode terang" : "Aktifkan mode gelap"
            }
            onPress={() => update({ darkMode: !themeDark })}
            style={styles.bell}
          >
            <Icon
              name={themeDark ? "sunny-outline" : "moon-outline"}
              color={C.rose}
            />
          </Pressable>
          <Pressable
            accessibilityLabel="Pengumuman"
            onPress={() => setScreen("notifications")}
            style={styles.bell}
          >
            <Icon name="notifications-outline" color={C.rose} />
            {data.notifications && unread + unreadEvents > 0 && (
              <View style={styles.dot}>
                <Text style={styles.dotText}>{unread + unreadEvents}</Text>
              </View>
            )}
          </Pressable>
        </View>
        <ClaySection style={styles.studentHero}>
          <View style={styles.heroCloudOne} />
          <View style={styles.heroCloudTwo} />
          <View style={styles.heroCopy}>
            <Text style={styles.heroEyebrow}>✦ RUANG BELAJAR</Text>
            <Text style={styles.heroTitle}>Semangat{"\n"}belajar!</Text>
            <Text style={styles.heroText}>
              Satu langkah kecil hari ini, selangkah lebih dekat ke mimpimu.
            </Text>
          </View>
          <FloatArt style={styles.heroArt}>
            <Text style={styles.heroEmoji}>📚</Text>
            <Text style={styles.heroStar}>✨</Text>
          </FloatArt>
        </ClaySection>
        <ClaySection style={styles.missionCard}>
          <View style={styles.missionTop}>
            <View style={styles.missionIcon}>
              <Text style={{ fontSize: 22 }}>🎯</Text>
            </View>
            <View style={{ flex: 1 }}>
              <Text style={styles.itemTitle}>Misi belajarmu</Text>
              <Text style={styles.smallMuted}>
                Selesaikan tugas di {data.childClass}
              </Text>
            </View>
            <Text style={styles.missionCount}>
              {
                data.tasks.filter(
                  (t) => t.className === data.childClass && data.results[t.id],
                ).length
              }
              /
              {data.tasks.filter((t) => t.className === data.childClass).length}
            </Text>
          </View>
          <View style={styles.missionTrack}>
            <View
              style={[
                styles.missionFill,
                {
                  width: `${data.tasks.filter((t) => t.className === data.childClass).length ? Math.round((data.tasks.filter((t) => t.className === data.childClass && data.results[t.id]).length / data.tasks.filter((t) => t.className === data.childClass).length) * 100) : 0}%`,
                },
              ]}
            />
          </View>
          <Text style={styles.smallMuted}>
            {activeTasks.length
              ? "Sedikit demi sedikit, kamu pasti bisa!"
              : "Hebat! Semua tugas sudah selesai."}
          </Text>
        </ClaySection>
        <View style={styles.stats}>
          <Stat
            icon="pencil"
            label="Tugas aktif"
            value={String(activeTasks.length)}
            desc="Menunggu dikerjakan"
            color={C.pink}
            onPress={() => changeTab("Tugas")}
          />
          <Stat
            icon="checkmark-circle"
            label="Selesai"
            value={String(
              data.tasks.filter(
                (t) => t.className === data.childClass && data.results[t.id],
              ).length,
            )}
            desc="Lihat riwayat"
            color={C.blue}
            onPress={() => {
              setTab("Tugas");
              setTaskFilter("Riwayat");
              setScreen("main");
            }}
          />
        </View>
        <Stat
          icon="book"
          label="Materi kelas"
          value={String(
            (data.materials || []).filter(
              (m) => m.className === data.childClass,
            ).length,
          )}
          desc="Buka ringkasan dan materi"
          color={C.blue}
          onPress={() => setScreen("materials")}
        />
        <View style={styles.sectionRow}>
          <Text style={styles.section}>Tugas per mata pelajaran</Text>
          <Pressable onPress={() => changeTab("Tugas")}>
            <Text style={styles.link}>Lihat semua ›</Text>
          </Pressable>
        </View>
        {subjectsForClass(data.childClass).map((subject) => {
          const list = activeTasks
            .filter((t) => t.subject === subject)
            .sort(
              (a, b) =>
                (a.dueAt ? new Date(a.dueAt).getTime() : Infinity) -
                (b.dueAt ? new Date(b.dueAt).getTime() : Infinity),
            );
          const next = list[0];
          return (
            <Item
              key={subject}
              item={{
                ...subjectInfo[subject],
                title: subject,
                meta: next
                  ? `${next.title} · ${deadlineLabel(next)}`
                  : "Tidak ada tugas aktif",
              }}
              status={next ? `${list.length} tugas` : "Lihat"}
              onPress={() => {
                setSubjectFilter(subject);
                setLearnerSubjectTab("Tugas");
                setTaskFilter("Aktif");
                setTab("Tugas");
                setScreen("main");
              }}
            />
          );
        })}
        <Pressable
          style={styles.tipCard}
          onPress={() => setTipIndex((tipIndex + 1) % 3)}
          accessibilityRole="button"
          accessibilityLabel="Lihat tips belajar berikutnya"
        >
          <View style={styles.tipIcon}>
            <PopIcon>
              <Text style={{ fontSize: 22 }}>💡</Text>
            </PopIcon>
          </View>
          <View style={{ flex: 1 }}>
            <Text style={styles.itemTitle}>Tips belajar</Text>
            <Text style={styles.smallMuted}>
              {
                [
                  "Baca soal pelan-pelan sebelum menjawab.",
                  "Istirahat sebentar jika kamu merasa lelah.",
                  "Tidak apa-apa bertanya jika belum mengerti.",
                ][tipIndex]
              }
            </Text>
          </View>
          <Icon name="refresh-outline" color={C.rose} />
        </Pressable>
      </>
    ) : (
      <>
        <SchoolIdentity compact />
        <View style={styles.greeting}>
          <View style={styles.avatar}>
            <PopIcon>
              <Text style={{ fontSize: 24 }}>{teacher ? "👩🏻‍🏫" : "D"}</Text>
            </PopIcon>
          </View>
          <View style={{ flex: 1 }}>
            <Text style={styles.smallMuted}>
              {teacher ? "Selamat datang," : "Orang tua dari"}
            </Text>
            <Text style={styles.name}>
              {teacher ? data.teacherName : data.studentName}
            </Text>
            <Text style={styles.smallMuted}>
              {teacher
                ? wali
                  ? "Wali kelas · SD Karitas Purwokerto"
                  : `Guru ${data.teacherSubject} · SD Karitas Purwokerto`
                : `${data.childClass} · SD Karitas Purwokerto`}
            </Text>
          </View>
          <Pressable
            accessibilityRole="button"
            accessibilityLabel={
              themeDark ? "Aktifkan mode terang" : "Aktifkan mode gelap"
            }
            onPress={() => update({ darkMode: !themeDark })}
            style={styles.bell}
          >
            <Icon
              name={themeDark ? "sunny-outline" : "moon-outline"}
              color={C.rose}
            />
          </Pressable>
          <Pressable
            accessibilityLabel="Pengumuman"
            onPress={() => setScreen("notifications")}
            style={styles.bell}
          >
            <Icon name="notifications-outline" color={C.rose} />
            {data.notifications && unread + unreadEvents > 0 && (
              <View style={styles.dot}>
                <Text style={styles.dotText}>{unread + unreadEvents}</Text>
              </View>
            )}
          </Pressable>
        </View>
        <Image
          source={
            teacher
              ? require("./assets/teacher-banner.png")
              : require("./assets/student-banner.png")
          }
          style={styles.banner}
          resizeMode="stretch"
        />
        {teacher && (
          <Chips
            options={["Semua kelas", ...CLASSES]}
            value={filter}
            onChange={setFilter}
          />
        )}
        <View style={styles.stats}>
          <Stat
            icon={teacher ? "people" : "pencil"}
            label={teacher ? "Kelas" : "Tugas Aktif"}
            value={
              teacher
                ? filter === "Semua kelas"
                  ? "6"
                  : "1"
                : String(activeTasks.length)
            }
            desc={teacher ? "Lihat kelas" : "Belum dikumpulkan"}
            color={C.blue}
            onPress={() => changeTab(teacher ? "Kelas" : "Tugas")}
          />
          <Stat
            icon={teacher ? "pencil" : "grid"}
            label={teacher ? "Tugas Aktif" : "Latihan"}
            value={
              teacher
                ? String(
                    educatorTasks.filter((t) => !data.results[t.id]).length,
                  )
                : String(visiblePractices.length - doneCount)
            }
            desc={teacher ? "Kelola tugas" : "Belum dikerjakan"}
            color={C.pink}
            onPress={() => changeTab(teacher ? "Tugas" : "Latihan")}
          />
        </View>
        {teacher && (
          <Stat
            icon="grid"
            label="Latihan"
            value={String(
              allPractices.filter(
                (p) => role !== "guru" || p.subject === data.teacherSubject,
              ).length,
            )}
            desc="Kelola latihan di kelas"
            color="#c47da1"
            onPress={() => changeTab("Kelas")}
          />
        )}
        <Stat
          icon="megaphone"
          label="Pengumuman"
          value={String(unread)}
          desc="Belum dibaca"
          color="#c47da1"
          onPress={() => setScreen("announcements")}
        />
        {!teacher && (
          <Card
            onPress={() => setScreen("progress")}
            style={styles.progressCard}
          >
            <View style={{ flex: 1 }}>
              <Text style={styles.overline}>RUANG TUMBUH</Text>
              <Text style={styles.itemTitle}>Perjalanan belajar ✨</Text>
              <Text style={styles.smallMuted}>
                Lihat bintang dan semangat belajarmu
              </Text>
            </View>
            <Text style={{ fontSize: 30 }}>🌟</Text>
            <Icon name="chevron-forward" color={C.rose} />
          </Card>
        )}
        <Stat
          icon="book"
          label="Materi"
          value={String(
            (data.materials || []).filter(
              (m) => teacher || m.className === data.childClass,
            ).length,
          )}
          desc={
            teacher
              ? "Kelola materi pembelajaran"
              : "Lihat materi untuk kelasmu"
          }
          color={C.blue}
          onPress={() => setScreen("materials")}
        />
        <View style={styles.sectionRow}>
          <Text style={styles.section}>
            {teacher ? "Tugas Terbaru" : "Tugas untukmu"}
          </Text>
          <Pressable onPress={() => changeTab("Tugas")}>
            <Text style={styles.link}>Lihat semua ›</Text>
          </Pressable>
        </View>
        {(teacher ? educatorTasks : activeTasks).slice(-2).map((t) => (
          <Item
            key={t.id}
            item={taskItem(t)}
            status={data.results[t.id] ? "Selesai" : "Aktif"}
            onPress={() => openTask(t)}
          />
        ))}
        {!activeTasks.length && !teacher && (
          <Text style={styles.muted}>Semua tugas sudah selesai. Hebat!</Text>
        )}
      </>
    );
  const tasks = () => {
    const list = data.tasks
      .filter(
        (t) =>
          !student || subjectFilter === "Semua" || t.subject === subjectFilter,
      )
      .filter((t) =>
        `${t.title} ${t.subject} ${t.className}`
          .toLowerCase()
          .includes(search.trim().toLowerCase()),
      )
      .filter((t) =>
        teacher
          ? (filter === "Semua kelas" || t.className === filter) &&
            (role !== "guru" || t.subject === data.teacherSubject) &&
            (taskFilter === "Semua" ||
              (taskFilter === "Selesai"
                ? !!data.results[t.id]
                : !data.results[t.id]))
          : t.className === data.childClass &&
            subjectsForClass(data.childClass).includes(t.subject) &&
            (taskFilter === "Riwayat"
              ? !!data.results[t.id]
              : !data.results[t.id]),
      );
    return (
      <>
        <Header
          title={
            student && subjectFilter !== "Semua"
              ? subjectFilter
              : teacher
                ? "Daftar Tugas"
                : "Tugas"
          }
          sub={
            teacher
              ? "Aktivitas kelas"
              : `${data.studentName} · ${data.childClass}`
          }
        />
        {student && (
          <>
            <Chips
              options={["Semua", ...subjectsForClass(data.childClass)]}
              value={subjectFilter}
              onChange={(v) => {
                setSubjectFilter(v);
                setLearnerSubjectTab("Tugas");
              }}
            />
            {subjectFilter !== "Semua" && (
              <Tabs
                options={["Tugas", "Latihan"]}
                value={learnerSubjectTab}
                onChange={setLearnerSubjectTab}
              />
            )}
          </>
        )}
        {student && learnerSubjectTab === "Latihan" ? (
          <>
            {visiblePractices
              .filter((p) => p.subject === subjectFilter)
              .map((p) => (
                <Item
                  key={p.id}
                  item={practiceItem(p)}
                  status={data.practiceDone[p.id] ? "Selesai" : "Kerjakan"}
                  onPress={() => {
                    setSelected(p);
                    setScreen("practiceDetail");
                  }}
                />
              ))}
          </>
        ) : (
          <>
            {teacher && (
              <TextInput
                value={search}
                onChangeText={setSearch}
                style={styles.input}
                placeholder="Cari tugas atau mata pelajaran..."
                accessibilityLabel="Cari tugas"
              />
            )}
            <Tabs
              options={
                teacher
                  ? ["Semua", "Berjalan", "Selesai"]
                  : ["Aktif", "Riwayat"]
              }
              value={taskFilter}
              onChange={setTaskFilter}
            />
            {teacher && (
              <Button
                title="+ Tambah tugas"
                onPress={() => openForm("taskForm")}
              />
            )}
            {role === "guru" && (
              <Button
                title="Rekap nilai per kelas"
                onPress={() =>
                  openGradeRecap(
                    filter === "Semua kelas" ? "Kelas 1" : filter,
                    "main",
                  )
                }
              />
            )}
            <ClaySection style={styles.note}>
              <Text style={styles.noteTitle}>📚 Semangat belajar!</Text>
              <Text style={styles.muted}>
                Kerjakan tugas sedikit demi sedikit setiap hari.
              </Text>
            </ClaySection>
            {list.map((t) => (
              <View key={t.id}>
                <Text style={styles.overline}>
                  {subjectInfo[t.subject].icon} {t.subject.toUpperCase()}
                </Text>
                <Item
                  item={taskItem(t)}
                  status={
                    data.results[t.id]
                      ? "Selesai"
                      : teacher
                        ? "Aktif"
                        : "Kerjakan"
                  }
                  onPress={() => openTask(t)}
                />
              </View>
            ))}
            {!list.length && (
              <Text style={styles.empty}>Belum ada tugas di sini.</Text>
            )}
          </>
        )}
      </>
    );
  };
  const practiceList = () => (
    <>
      <Header
        title="Latihan"
        sub={`${doneCount} dari ${visiblePractices.length} selesai · soal esai`}
      />
      {visiblePractices.map((p) => (
        <View key={p.id}>
          <Text style={styles.overline}>
            {subjectInfo[p.subject].icon} {p.subject.toUpperCase()}
          </Text>
          <Item
            item={practiceItem(p)}
            status={data.practiceDone[p.id] ? "Selesai" : "Kerjakan"}
            onPress={() => {
              setSelected(p);
              setScreen("practiceDetail");
            }}
          />
        </View>
      ))}
    </>
  );
  const classes = () => {
    const currentClass = filter === "Semua kelas" ? "Kelas 1" : filter;
    const classTasks = educatorTasks.filter(
      (t) => t.className === currentClass,
    );
    const classPractices = allPractices.filter(
      (p) =>
        (!p.className || p.className === currentClass) &&
        (role !== "guru" || p.subject === data.teacherSubject),
    );
    const completed = classTasks.filter((t) => data.results[t.id]).length;
    const percentage = classTasks.length
      ? Math.round((completed / classTasks.length) * 100)
      : 0;
    return (
      <>
        <Header title="Kelas Saya" sub="Ruang belajar" />
        <Chips options={CLASSES} value={currentClass} onChange={setFilter} />
        <ClaySection style={styles.classReferenceHero}>
          <View style={{ flex: 1 }}>
            <Text style={styles.classTitle}>{currentClass}</Text>
            <Text style={styles.muted}>Belajar seru, tumbuh bersama.</Text>
            <Text style={styles.smallMuted}>Tahun ajaran 2026/2027</Text>
          </View>
          <PopIcon>
            <Text style={{ fontSize: 68 }}>🏫</Text>
          </PopIcon>
        </ClaySection>
        <View style={styles.tilesGrid}>
          <Pressable
            onPress={() => setScreen("students")}
            style={[
              styles.classTile,
              { backgroundColor: themeDark ? "#583d47" : "#fbd5d7" },
            ]}
          >
            <Text style={styles.tileLabel}>Jumlah siswa</Text>
            <Text style={styles.tileNumber}>3</Text>
            <Text style={styles.smallMuted}>Data contoh</Text>
          </Pressable>
          <Pressable
            onPress={() => {
              setDraftSubject(data.teacherSubject);
              setSubjectTab("Latihan");
              setScreen("subject");
            }}
            style={[
              styles.classTile,
              { backgroundColor: themeDark ? "#354b41" : "#d1f4d8" },
            ]}
          >
            <Text style={styles.tileLabel}>Materi latihan</Text>
            <Text style={styles.tileNumber}>{classPractices.length}</Text>
            <Text style={styles.smallMuted}>Lihat latihan</Text>
          </Pressable>
          <Pressable
            onPress={() => changeTab("Tugas")}
            style={[
              styles.classTile,
              { backgroundColor: themeDark ? "#493b50" : "#edd7ef" },
            ]}
          >
            <Text style={styles.tileLabel}>Tugas berjalan</Text>
            <Text style={styles.tileNumber}>
              {classTasks.length - completed}
            </Text>
            <Text style={styles.smallMuted}>Lihat tugas</Text>
          </Pressable>
          <Pressable
            onPress={() => changeTab("Tugas")}
            style={[
              styles.classTile,
              { backgroundColor: themeDark ? "#504639" : "#f7eddd" },
            ]}
          >
            <Text style={styles.tileLabel}>Tugas selesai</Text>
            <Text style={styles.tileNumber}>{percentage}%</Text>
            <Text style={styles.smallMuted}>Data demo</Text>
          </Pressable>
        </View>
        <View style={styles.sectionRow}>
          <Text style={styles.section}>Daftar Siswa</Text>
          <Pressable onPress={() => setScreen("students")}>
            <Text style={styles.link}>Lihat semua ›</Text>
          </Pressable>
        </View>
        {[data.studentName, "Sari Putri", "Rafi Pratama"].map((n, i) => (
          <Item
            key={n}
            item={{
              icon: i === 2 ? "👦🏻" : "🙂",
              title: n,
              meta:
                i === 0
                  ? `${Object.keys(data.results).length} tugas selesai`
                  : "Siswa aktif · data contoh",
              color: "#f8ebec",
            }}
            status="Aktif"
            onPress={() => {
              setSelected({
                title: n,
                body:
                  i === 0
                    ? `${Object.keys(data.results).length} tugas selesai dan ${doneCount} latihan selesai di perangkat ini.`
                    : "Data siswa contoh.",
              });
              setScreen("studentDetail");
            }}
          />
        ))}
        <Text style={styles.section}>Mata Pelajaran</Text>
        {(role === "guru" ? [data.teacherSubject] : subjects)
          .filter((subject) => subjectsForClass(currentClass).includes(subject))
          .map((subject) => (
            <Item
              key={subject}
              item={{
                ...subjectInfo[subject],
                title: subject,
                meta: `${currentClass} · Lihat tugas dan latihan`,
              }}
              onPress={() => {
                setDraftSubject(subject);
                setSubjectTab("Tugas");
                setScreen("subject");
              }}
            />
          ))}
      </>
    );
  };
  const calendar = () => {
    let date = new Date(year, month, 1),
      first = (date.getDay() + 6) % 7,
      days = new Date(year, month + 1, 0).getDate();
    const move = (n) => {
      let d = new Date(year, month + n, 1);
      setMonth(d.getMonth());
      setYear(d.getFullYear());
      setDay(1);
    };
    return (
      <>
        <Header title="Kalender" sub="Agenda dan kegiatan sekolah" />
        <View style={styles.calendarHeader}>
          <Pressable
            accessibilityLabel="Bulan sebelumnya"
            onPress={() => move(-1)}
          >
            <Icon name="chevron-back" />
          </Pressable>
          <Text style={styles.section}>
            {date.toLocaleDateString("id-ID", {
              month: "long",
              year: "numeric",
            })}
          </Text>
          <Pressable
            accessibilityLabel="Bulan berikutnya"
            onPress={() => move(1)}
          >
            <Icon name="chevron-forward" />
          </Pressable>
        </View>
        <View style={styles.grid}>
          {["Sen", "Sel", "Rab", "Kam", "Jum", "Sab", "Min"].map((x) => (
            <Text key={x} style={styles.dayLabel}>
              {x}
            </Text>
          ))}
          {Array.from({ length: first }, (_, i) => (
            <Text key={"b" + i} style={styles.day} />
          ))}
          {Array.from({ length: days }, (_, i) => (
            <Text
              onPress={() => setDay(i + 1)}
              key={i}
              style={[styles.day, day === i + 1 && styles.today]}
            >
              {i + 1}
            </Text>
          ))}
        </View>
        <Text style={styles.section}>
          Agenda · {day}{" "}
          {date.toLocaleDateString("id-ID", { month: "long", year: "numeric" })}
        </Text>
        {year === 2026 && month === 10 && (day === 6 || day === 7) ? (
          <Item
            item={{
              icon: "📣",
              title: day === 6 ? "Hari Literasi KARSA" : "Pertemuan Wali Murid",
              meta: "Kegiatan sekolah",
              color: "#f8ebec",
            }}
            onPress={() =>
              openAnnouncement(
                data.announcements.find(
                  (a) => a.id === (day === 6 ? "a1" : "a2"),
                ) || initialAnnouncements[day === 6 ? 0 : 1],
              )
            }
          />
        ) : (
          <Text style={styles.muted}>Tidak ada agenda pada tanggal ini.</Text>
        )}
      </>
    );
  };
  const profile = () => (
    <>
      <Header
        title={
          teacher ? (wali ? "Profil Wali Kelas" : "Profil Guru") : "Profil Anak"
        }
        sub="Senang bertemu denganmu!"
      />
      {!teacher && (
        <ClaySection style={styles.note}>
          <Text style={styles.noteTitle}>
            🌟 Semangat belajar, {data.studentName}!
          </Text>
          <Text style={styles.muted}>
            {activeTasks.length
              ? `Ada ${activeTasks.length} tugas yang belum dikumpulkan.`
              : "Semua tugas sudah selesai. Hebat!"}
          </Text>
        </ClaySection>
      )}
      <ClaySection style={styles.profileHero}>
        <View style={styles.bigAvatar}>
          <Text style={{ fontSize: 42 }}>{teacher ? "👩🏻‍🏫" : "👦🏻"}</Text>
        </View>
        <Text style={styles.name}>
          {teacher ? data.teacherName : data.studentName}
        </Text>
        <Text style={styles.muted}>
          {teacher
            ? wali
              ? "Wali kelas · SD Karitas Purwokerto"
              : `Guru ${data.teacherSubject} · SD Karitas Purwokerto`
            : `${data.childClass} · SD Karitas Purwokerto`}
        </Text>
        <Text style={styles.profileBadge}>
          {teacher ? "Guru aktif" : "Siswa aktif"}
        </Text>
      </ClaySection>
      <Text style={styles.section}>
        {teacher
          ? "Informasi Guru"
          : student
            ? "Aktivitas Tugas"
            : "Perjalanan Belajarku"}
      </Text>
      <Card>
        <Text style={styles.itemTitle}>
          {teacher
            ? "Mata Pelajaran"
            : student
              ? "Semangat mengerjakan tugas!"
              : "Terus bertumbuh! 🌱"}
        </Text>
        <Text style={styles.muted}>
          {teacher
            ? wali
              ? "Matematika · Bahasa Indonesia · IPA"
              : data.teacherSubject
            : student
              ? `${data.tasks.filter((t) => t.className === data.childClass && data.results[t.id]).length} tugas selesai.`
              : `${Object.keys(data.results).length} tugas dan ${doneCount} latihan selesai.`}
        </Text>
      </Card>
      {teacher && (
        <>
          <Text style={[styles.section, { marginTop: 14 }]}>
            Informasi Guru
          </Text>
          <Card>
            <Text style={styles.smallMuted}>Kelas diampu</Text>
            <Text style={styles.itemTitle}>Kelas 1 sampai Kelas 6</Text>
            <Text style={[styles.smallMuted, { marginTop: 10 }]}>NIP demo</Text>
            <Text style={styles.itemTitle}>{ACCOUNTS[role].id}</Text>
          </Card>
          <Text style={styles.section}>Ringkasan Aktivitas</Text>
          <View style={styles.stats}>
            <Stat
              icon="checkmark"
              label="Tugas Aktif"
              value={String(
                educatorTasks.filter((t) => !data.results[t.id]).length,
              )}
              desc="Lihat tugas"
              color={C.blue}
              onPress={() => changeTab("Tugas")}
            />
            <Stat
              icon="albums"
              label="Kuis Dibuat"
              value={String(educatorTasks.length)}
              desc="Data demo"
              color={C.pink}
              onPress={() => changeTab("Tugas")}
            />
          </View>
          <View style={styles.stats}>
            <Stat
              icon="people"
              label="Siswa"
              value="3"
              desc="Data contoh"
              color="#c47da1"
              onPress={() => setScreen("students")}
            />
            <Stat
              icon="checkmark-done"
              label="Perlu Diperiksa"
              value={String(
                educatorTasks.filter(
                  (t) => data.results[t.id] && !data.reviewed.includes(t.id),
                ).length,
              )}
              desc="Hasil baru"
              color="#84b99c"
              onPress={() => changeTab("Tugas")}
            />
          </View>
        </>
      )}
      <Text style={[styles.section, { marginTop: 20 }]}>Pengaturan</Text>
      {[
        "Informasi pribadi",
        ...(role === "guru" ? ["Mata pelajaran"] : []),
        "Tampilan",
        "Notifikasi",
        "Privasi dan keamanan",
        "Pusat bantuan",
      ].map((x, i) => (
        <Card
          key={x}
          onPress={() => {
            setSetting(x);
            setDraftTitle(teacher ? data.teacherName : data.studentName);
            setScreen("setting");
          }}
          style={styles.setting}
        >
          <Icon
            name={
              x === "Informasi pribadi"
                ? "person-outline"
                : x === "Tampilan"
                  ? "moon-outline"
                  : x === "Notifikasi"
                    ? "notifications-outline"
                    : x === "Mata pelajaran"
                      ? "book-outline"
                      : x === "Privasi dan keamanan"
                        ? "shield-checkmark-outline"
                        : "help-circle-outline"
            }
            color={C.rose}
          />
          <Text style={[styles.itemTitle, { flex: 1, marginLeft: 12 }]}>
            {x}
          </Text>
          <Icon name="chevron-forward" size={17} color={C.muted} />
        </Card>
      ))}
      <Pressable
        onPress={() => {
          setRole(null);
          setScreen("welcome");
          setUsername("");
          setPassword("");
        }}
        style={styles.logout}
      >
        <Text style={styles.link}>Keluar dari akun demo</Text>
      </Pressable>
    </>
  );
  let content;
  if (screen === "splash") content = null;
  else if (screen === "welcome")
    content = (
      <View style={styles.welcome}>
        <View style={styles.welcomeTop}>
          <Text style={[styles.brand, { marginTop: 0, marginBottom: 0 }]}>
            ✿ KARSA
          </Text>
          <Pressable
            accessibilityRole="button"
            accessibilityLabel={
              themeDark ? "Aktifkan mode terang" : "Aktifkan mode gelap"
            }
            onPress={() => update({ darkMode: !themeDark })}
            style={styles.bell}
          >
            <Icon
              name={themeDark ? "sunny-outline" : "moon-outline"}
              color={C.rose}
            />
          </Pressable>
        </View>
        <SchoolIdentity />
        <Text style={styles.welcomeTitle}>Selamat datang di KARSA</Text>
        <Text style={styles.muted}>Pilih peran Anda untuk melanjutkan</Text>
        {[
          {
            r: "wali",
            emoji: "👩🏻‍🏫",
            title: "Saya Wali Kelas",
            sub: "Pantau kelas, siswa, dan perkembangan belajar.",
          },
          {
            r: "guru",
            emoji: "📚",
            title: "Saya Guru Mata Pelajaran",
            sub: "Kelola tugas berdasarkan mata pelajaran dan kelas.",
          },
          {
            r: "orangtua",
            emoji: "👩🏻",
            title: "Saya Orang Tua/Wali",
            sub: "Dampingi anak kelas 1–4 belajar dan mengerjakan tugas.",
          },
          {
            r: "siswa",
            emoji: "🎒",
            title: "Saya Siswa",
            sub: "Kelas 5–6: lihat dan kerjakan tugas secara mandiri.",
          },
        ].map((x, i) => (
          <Pressable
            key={x.r}
            style={[
              styles.role,
              {
                backgroundColor: themeDark
                  ? i === 1
                    ? "#34414e"
                    : "#493640"
                  : i === 1
                    ? "#edf4f8"
                    : "#fbeaec",
                borderColor: themeDark
                  ? "#66535e"
                  : i === 1
                    ? "#c9dfea"
                    : "#f2ced4",
              },
            ]}
            onPress={() => {
              setRole(x.r);
              setUsername("");
              setPassword("");
              setShowPassword(false);
              setError("");
              setScreen("login");
            }}
          >
            <View style={styles.roleAvatar}>
              <PopIcon>
                <Text style={{ fontSize: 29 }}>{x.emoji}</Text>
              </PopIcon>
            </View>
            <View style={{ flex: 1 }}>
              <Text style={styles.itemTitle}>{x.title}</Text>
              <Text style={styles.smallMuted}>{x.sub}</Text>
            </View>
            <Icon name="chevron-forward" color={C.rose} />
          </Pressable>
        ))}
        <Text style={styles.quote}>
          Karena setiap anak{"\n"}punya potensi yang{"\n"}berharga ♥
        </Text>
        <Text style={styles.demo}>PROTOTIPE PEMBELAJARAN · KARSA</Text>
      </View>
    );
  else if (screen === "login")
    content = (
      <View style={styles.loginPage}>
        <View style={styles.loginHero}>
          <View style={styles.loginCirclePink} />
          <View style={styles.loginCircleBlue} />
          <Pressable
            accessibilityLabel="Kembali"
            onPress={() => setScreen("welcome")}
            style={styles.loginBack}
          >
            <Icon name="chevron-back" color={C.ink} size={23} />
          </Pressable>
          <Image
            source={require("./assets/karsa-login-logo.png")}
            style={styles.loginLogo}
            resizeMode="contain"
          />
        </View>
        <View style={styles.loginBody}>
          <SchoolIdentity compact />
          <Pressable
            onPress={() => update({ darkMode: !themeDark })}
            style={{ alignSelf: "flex-end", padding: 8 }}
            accessibilityLabel="Ubah mode terang atau gelap"
          >
            <Icon
              name={themeDark ? "sunny-outline" : "moon-outline"}
              color={C.rose}
            />
          </Pressable>
          <Text style={styles.loginTitle}>
            {wali
              ? "Selamat datang,\nWali Kelas!"
              : teacher
                ? "Selamat datang,\nGuru!"
                : student
                  ? "Halo, Siswa!"
                  : "Halo, Orang Tua!"}
          </Text>
          <Text style={styles.loginSubtitle}>
            {student
              ? "Untuk siswa kelas 5–6"
              : role === "orangtua"
                ? "Untuk pendamping anak kelas 1–4"
                : "Masuk untuk melanjutkan"}
          </Text>
          <View style={styles.loginField}>
            <Icon
              name={teacher ? "card-outline" : "person-outline"}
              color="#728cab"
              size={22}
            />
            <TextInput
              accessibilityLabel={teacher ? "NIP" : "NISN"}
              style={styles.loginInput}
              value={username}
              onChangeText={setUsername}
              placeholder={teacher ? "NIP" : "NISN"}
              placeholderTextColor="#9aaabd"
              autoCapitalize="none"
              autoCorrect={false}
            />
          </View>
          <View style={styles.loginField}>
            <Icon name="lock-closed-outline" color="#728cab" size={22} />
            <TextInput
              accessibilityLabel="Kata sandi"
              style={styles.loginInput}
              value={password}
              onChangeText={setPassword}
              placeholder="Kata sandi"
              placeholderTextColor="#9aaabd"
              secureTextEntry={!showPassword}
            />
            <Pressable
              accessibilityLabel={
                showPassword ? "Sembunyikan kata sandi" : "Tampilkan kata sandi"
              }
              onPress={() => setShowPassword((v) => !v)}
              style={{ padding: 4 }}
            >
              <Icon
                name={showPassword ? "eye-off-outline" : "eye-outline"}
                color="#728cab"
                size={22}
              />
            </Pressable>
          </View>
          {!!error && <Text style={styles.noteTitle}>{error}</Text>}
          <Pressable
            onPress={() => setScreen("forgot")}
            style={styles.forgotLink}
          >
            <Text style={styles.link}>Lupa kata sandi?</Text>
          </Pressable>
          <Pressable
            accessibilityRole="button"
            onPress={() => {
              if (
                username.trim() !== ACCOUNTS[role].id ||
                password !== ACCOUNTS[role].password
              ) {
                setError("NIP/NISN atau kata sandi tidak sesuai.");
                return;
              }
              if (role === "siswa")
                update({
                  childClass: STUDENT_CLASSES.includes(data.studentClass)
                    ? data.studentClass
                    : "Kelas 5",
                });
              if (role === "orangtua")
                update({
                  childClass: PARENT_CLASSES.includes(data.parentClass)
                    ? data.parentClass
                    : "Kelas 1",
                });
              setError("");
              setFilter(role === "wali" ? WALI_CLASS : "Semua kelas");
              setTab("Beranda");
              setScreen("main");
            }}
            style={styles.loginButton}
          >
            <Text style={styles.loginButtonText}>Masuk →</Text>
          </Pressable>
          <View style={styles.demoAccount}>
            <Text style={styles.itemTitle}>
              Akun demo · {ACCOUNTS[role].label}
            </Text>
            <Text style={styles.muted}>
              {teacher ? "NIP" : "NISN"}: {ACCOUNTS[role].id}
            </Text>
            <Text style={styles.muted}>
              Kata sandi: {ACCOUNTS[role].password}
            </Text>
            <Text style={styles.smallMuted}>
              Akun contoh untuk mencoba aplikasi, bukan autentikasi aman.
            </Text>
          </View>
        </View>
        <View style={styles.loginWavePink} />
        <View style={styles.loginWaveBlue} />
      </View>
    );
  else if (screen === "forgot")
    content = (
      <>
        <Header
          title="Lupa kata sandi?"
          sub="Akun ini hanya untuk demonstrasi"
          back={() => setScreen("login")}
        />
        <Card>
          <Text style={styles.itemTitle}>Informasi akun demo</Text>
          <Text style={styles.muted}>
            {teacher ? "NIP" : "NISN anak"}: {ACCOUNTS[role].id}
          </Text>
          <Text style={styles.muted}>
            Kata sandi: {ACCOUNTS[role].password}
          </Text>
          <Text style={styles.smallMuted}>
            Belum tersedia pemulihan akun sungguhan.
          </Text>
        </Card>
        <Button title="Kembali masuk" onPress={() => setScreen("login")} />
      </>
    );
  else if (screen === "main")
    content = wali
      ? tab === "Beranda"
        ? waliHome()
        : tab === "Anggota"
          ? waliMembers()
          : tab === "Rekap"
            ? waliRecap()
            : tab === "Agenda"
              ? waliAgenda()
              : waliProfile()
      : tab === "Beranda"
        ? dashboard()
        : tab === "Tugas"
          ? tasks()
          : tab === "Latihan"
            ? practiceList()
            : tab === "Kelas"
              ? classes()
              : tab === "Kalender"
                ? calendar()
                : profile();
  else if (screen === "waliMember") {
    const member = classMembers.find((m) => m.id === memberId);
    content = member ? (
      <>
        <Header
          title={member.name}
          sub={`${WALI_CLASS} · data contoh`}
          back={() => {
            setTab("Anggota");
            setScreen("main");
          }}
        />
        <ClaySection style={styles.profileHero}>
          <View style={styles.bigAvatar}>
            <Text style={{ fontSize: 42 }}>{member.icon}</Text>
          </View>
          <Text style={styles.name}>{member.name}</Text>
          <Text style={styles.muted}>{WALI_CLASS} · Siswa aktif</Text>
        </ClaySection>
        <Card>
          <Text style={styles.itemTitle}>Kehadiran hari ini</Text>
          <Text style={styles.muted}>
            {todayAttendance[member.id] || "Belum dicatat"}
          </Text>
          <Button
            title="Isi kehadiran"
            onPress={() => {
              setRecapDate(todayKey);
              setRecapTab("Kehadiran");
              changeTab("Rekap");
            }}
          />
        </Card>
        <Text style={styles.section}>Nilai ringkas</Text>
        <Text style={[styles.muted, { marginBottom: 12 }]}>
          Masukkan nilai contoh 0–100. Ini bukan nilai resmi atau nilai per mata
          pelajaran.
        </Text>
        <TextInput
          style={styles.input}
          keyboardType="decimal-pad"
          value={scoreDraft}
          onChangeText={setScoreDraft}
          placeholder="Mis. 85"
          accessibilityLabel="Nilai ringkas"
        />
        {!!error && <Text style={styles.noteTitle}>{error}</Text>}
        <Button title="Simpan nilai" onPress={saveScore} />
        {typeof classScores[memberId] === "number" && (
          <Pressable
            style={styles.logout}
            onPress={() => {
              const scores = { ...classScores };
              delete scores[memberId];
              update({ classScores: scores });
              setScoreDraft("");
              setTab("Rekap");
              setRecapTab("Nilai");
              setScreen("main");
            }}
          >
            <Text style={styles.link}>Hapus nilai</Text>
          </Pressable>
        )}
      </>
    ) : (
      <>
        <Header title="Siswa tidak ditemukan" back={() => setScreen("main")} />
      </>
    );
  } else if (screen === "agendaForm")
    content = (
      <>
        <Header
          title="Tambah agenda kelas"
          sub={WALI_CLASS}
          back={() => {
            setTab("Agenda");
            setScreen("main");
          }}
        />
        <Text style={styles.label}>Judul agenda</Text>
        <TextInput
          style={styles.input}
          value={draftTitle}
          onChangeText={setDraftTitle}
          placeholder="Mis. Pertemuan orang tua"
        />
        <Text style={styles.label}>Tanggal (YYYY-MM-DD)</Text>
        <TextInput
          style={styles.input}
          value={eventDate}
          onChangeText={setEventDate}
          placeholder="2026-11-07"
          autoCapitalize="none"
        />
        <Text style={styles.label}>Catatan (opsional)</Text>
        <TextInput
          multiline
          textAlignVertical="top"
          style={[styles.input, { minHeight: 100 }]}
          value={draftBody}
          onChangeText={setDraftBody}
          placeholder="Tambahkan catatan kegiatan"
        />
        {!!error && <Text style={styles.noteTitle}>{error}</Text>}
        <Button title="Simpan agenda" onPress={saveEvent} />
        <Text style={styles.loginNote}>
          Agenda dan pemberitahuan disimpan pada perangkat ini.
        </Text>
      </>
    );
  else if (screen === "agendaDetail")
    content = (
      <>
        <Header
          title={selected.title}
          sub={`${selected.className} · ${selected.date}`}
          back={() => {
            setTab(wali ? "Agenda" : "Beranda");
            setScreen("main");
          }}
        />
        <Card>
          <Text style={styles.itemTitle}>📅 {selected.date}</Text>
          <Text style={[styles.muted, { marginTop: 10 }]}>
            {selected.body || "Tidak ada catatan tambahan."}
          </Text>
          <Text style={[styles.smallMuted, { marginTop: 10 }]}>
            Dibuat oleh {selected.teacher}
          </Text>
        </Card>
      </>
    );
  else if (screen === "notifications")
    content = (
      <>
        <Header
          title="Notifikasi"
          sub="Pembaruan pembelajaran di perangkat ini"
          back={() => setScreen("main")}
        />
        {!!notice && (
          <View style={styles.note}>
            <Text style={styles.muted}>{notice}</Text>
          </View>
        )}
        {relevantNotifications.map((n) => (
          <Item
            key={n.id}
            item={{
              icon:
                n.target === "teachers"
                  ? "✅"
                  : n.kind === "material"
                    ? "📚"
                    : "📝",
              title: n.title,
              meta: `${n.subject} · ${n.className} · ${new Date(n.createdAt).toLocaleString("id-ID")}`,
              color: "#f8ebec",
            }}
            status={
              ((data.readNotifications || {})[notificationKey] || []).includes(
                n.id,
              )
                ? "Dibaca"
                : "Baru"
            }
            onPress={() => markNotification(n)}
          />
        ))}
        {!relevantNotifications.length && (
          <Text style={styles.empty}>Belum ada pemberitahuan baru.</Text>
        )}
        <Button
          title={`Pengumuman sekolah (${unread})`}
          onPress={() => setScreen("announcements")}
        />
        <Text style={styles.loginNote}>
          Notifikasi demo hanya muncul pada perangkat/browser yang sama, bukan
          push notification.
        </Text>
      </>
    );
  else if (screen === "materials") {
    const list = (data.materials || []).filter((m) =>
      teacher
        ? (filter === "Semua kelas" || m.className === filter) &&
          (role !== "guru" || m.subject === data.teacherSubject)
        : m.className === data.childClass,
    );
    content = (
      <>
        <Header
          title="Materi belajar"
          sub={
            teacher
              ? "Kelola materi dan ringkasan"
              : "Materi untuk " + data.childClass
          }
          back={() => setScreen("main")}
        />
        {teacher && (
          <Button
            title="+ Unggah materi"
            onPress={() => openForm("materialForm")}
          />
        )}
        <Text style={[styles.muted, { marginVertical: 12 }]}>
          Materi dan ringkasan tersimpan di perangkat ini.
        </Text>
        {list.map((m) => (
          <Item
            key={m.id}
            item={{
              ...subjectInfo[m.subject],
              title: m.title,
              meta: `${m.subject} · ${m.className} · ${m.teacher}`,
            }}
            status="Lihat"
            onPress={() => {
              setSelected(m);
              setError("");
              setScreen("materialDetail");
            }}
          />
        ))}
        {!list.length && (
          <Text style={styles.empty}>Belum ada materi untuk ditampilkan.</Text>
        )}
      </>
    );
  } else if (screen === "materialDetail")
    content = (
      <>
        <Header
          title={selected.title}
          sub={`${selected.subject} · ${selected.className} · ${selected.teacher}`}
          back={() => setScreen("materials")}
        />
        {selected.file && (
          <Card>
            <Text style={styles.itemTitle}>📎 {selected.file.name}</Text>
            <Text style={styles.smallMuted}>File materi lokal</Text>
            <Button
              title="Buka file materi"
              onPress={() => openAttachment(selected.file)}
            />
          </Card>
        )}
        <Text style={styles.section}>Ringkasan materi</Text>
        <Card>
          <Text style={[styles.muted, { lineHeight: 23 }]}>
            {selected.summary || "Belum ada ringkasan."}
          </Text>
        </Card>
        {!!error && <Text style={styles.noteTitle}>{error}</Text>}
        <Text style={styles.loginNote}>
          Ringkasan dipilih atau ditulis oleh guru, bukan AI otomatis.
        </Text>
      </>
    );
  else if (screen === "materialForm")
    content = (
      <>
        <Header
          title="Tambah materi"
          sub="File dan ringkasan untuk kelas"
          back={() => setScreen("materials")}
        />
        <Text style={styles.label}>Judul materi</Text>
        <TextInput
          style={styles.input}
          value={draftTitle}
          onChangeText={setDraftTitle}
          placeholder="Mis. Ekosistem"
        />
        <Text style={styles.label}>Mata pelajaran</Text>
        <Chips
          options={
            role === "guru" ? [data.teacherSubject] : Object.keys(subjectInfo)
          }
          value={draftSubject}
          onChange={setDraftSubject}
        />
        <Text style={styles.label}>Untuk kelas</Text>
        <Chips
          options={
            draftSubject === "Ilmu Pengetahuan Alam dan Sosial (IPAS)"
              ? CLASSES.slice(2)
              : CLASSES
          }
          value={draftClass}
          onChange={setDraftClass}
        />
        <Button
          title={attachment ? "Ganti file materi" : "Unggah PDF / file materi"}
          onPress={pickAttachment}
        />
        {attachment && (
          <Text style={[styles.muted, { marginTop: 8 }]}>
            📎 {attachment.name}
          </Text>
        )}
        <View style={styles.note}>
          <Text style={styles.noteTitle}>Asisten ringkasan · demo offline</Text>
          <Text style={styles.muted}>
            Untuk .txt, teks dibaca otomatis. Untuk PDF atau dokumen lain,
            tempel teks di bawah ini. Tombol memilih tiga kalimat pertama; bukan
            AI dan tidak membaca PDF otomatis.
          </Text>
        </View>
        <Text style={styles.label}>Teks materi</Text>
        <TextInput
          multiline
          textAlignVertical="top"
          style={[styles.input, { minHeight: 100 }]}
          value={sourceText}
          onChangeText={setSourceText}
          placeholder="Tempel teks materi di sini..."
        />
        <Button title="Ringkas teks (offline)" onPress={summarizeOffline} />
        <Text style={[styles.label, { marginTop: 14 }]}>
          Ringkasan (dapat diedit)
        </Text>
        <TextInput
          multiline
          textAlignVertical="top"
          style={[styles.input, { minHeight: 100 }]}
          value={summaryText}
          onChangeText={setSummaryText}
          placeholder="Tulis atau periksa ringkasan..."
        />
        {!!error && <Text style={styles.noteTitle}>{error}</Text>}
        {!!notice && <Text style={styles.smallMuted}>{notice}</Text>}
        <Button title="Simpan materi" onPress={saveMaterial} />
        <Text style={styles.loginNote}>
          Batas file: web 1 MB; perangkat 10 MB. Data tidak disinkronkan.
        </Text>
      </>
    );
  else if (screen === "announcements")
    content = (
      <>
        <Header
          title="Pengumuman"
          sub="Info penting untuk keluarga"
          back={() => setScreen("main")}
        />
        {teacher && (
          <Button
            title="+ Buat pengumuman"
            onPress={() => openForm("announcementForm")}
          />
        )}
        <Text style={[styles.muted, { marginVertical: 12 }]}>
          Ikuti kabar terbaru dan agenda kegiatan sekolah.
        </Text>
        {visibleAnnouncements.map((a) => (
          <Card
            key={a.id}
            onPress={() => openAnnouncement(a)}
            style={{ padding: 20 }}
          >
            <Text style={styles.overline}>
              {a.category}{" "}
              {!data.readAnnouncements.includes(a.id) ? "· BARU" : ""}
            </Text>
            <Text style={styles.section}>{a.title}</Text>
            <Text style={styles.link}>{a.detail}</Text>
            <Text
              numberOfLines={2}
              style={[styles.muted, { marginTop: 8, lineHeight: 21 }]}
            >
              {a.body}
            </Text>
            <Text style={[styles.link, { marginTop: 12 }]}>Baca detail ›</Text>
          </Card>
        ))}
      </>
    );
  else if (screen === "announcementDetail")
    content = (
      <>
        <Header
          title={selected.title}
          sub={selected.category}
          back={() => setScreen("announcements")}
        />
        <Text style={styles.link}>{selected.detail}</Text>
        <Text
          style={[
            styles.muted,
            { fontSize: 15, lineHeight: 25, marginVertical: 20 },
          ]}
        >
          {selected.body}
        </Text>
        <Text style={styles.smallMuted}>Untuk: {selected.className}</Text>
        <Button
          title="Kembali ke pengumuman"
          onPress={() => setScreen("announcements")}
        />
      </>
    );
  else if (screen === "taskDetail" || screen === "practiceDetail") {
    let isTask = screen === "taskDetail",
      result = data.results[selected.id];
    content = (
      <>
        <Header
          title={selected.title}
          sub={`${selected.subject} · ${selected.className || "Latihan"}`}
          back={() => setScreen("main")}
        />
        <ClaySection style={styles.detailIcon}>
          <Text style={{ fontSize: 48 }}>
            {subjectInfo[selected.subject].icon}
          </Text>
        </ClaySection>
        <Text style={styles.section}>
          {isTask ? "Siap mengerjakan tugas?" : "Belajar dengan santai ✨"}
        </Text>
        <Text style={[styles.muted, { lineHeight: 23, marginVertical: 14 }]}>
          {isTask
            ? selected.kind === "file"
              ? "Buka file tugas. Setelah mengerjakan, tandai selesai di perangkat ini. Jawaban tidak dikirim otomatis."
              : "10 soal pilihan ganda. Pilih jawaban lalu lihat hasil setelah selesai. Waktu hanya informasi dalam demo."
            : "5 soal esai. Tulis jawabanmu, lalu bandingkan dengan contoh. Latihan tidak dinilai; status selesai tercatat lokal."}
        </Text>
        {result?.demo && (
          <Text style={styles.smallMuted}>
            Ini adalah riwayat contoh, bukan nilai siswa sebenarnya.
          </Text>
        )}
        {result && (
          <Text style={styles.noteTitle}>
            {result.submittedOnly
              ? "Tugas ditandai selesai"
              : `Hasil terakhir: ${result.score} / ${result.total}`}
          </Text>
        )}
        {isTask && (
          <Card>
            <Text style={styles.itemTitle}>Tenggat: {formatDue(selected)}</Text>
            <Text style={styles.smallMuted}>
              {deadlineLabel(selected)} · tugas tidak dikunci otomatis
            </Text>
          </Card>
        )}
        {isTask && selected.kind === "file" ? (
          <>
            <Button
              title="Buka file tugas"
              onPress={() => openAttachment(selected.file)}
            />
            {!result && (
              <Button
                title="Tandai sudah dikerjakan"
                onPress={submitFileTask}
              />
            )}
            <Text style={styles.smallMuted}>
              Penanda ini tidak mengirim jawaban atau membuktikan pengumpulan.
            </Text>
          </>
        ) : (
          <Button
            title={
              result
                ? "Kerjakan lagi"
                : isTask
                  ? "Mulai mengerjakan"
                  : "Mulai latihan"
            }
            onPress={isTask ? startQuiz : practiceStart}
          />
        )}
        {!!error && <Text style={styles.noteTitle}>{error}</Text>}
      </>
    );
  } else if (screen === "quiz")
    content = (
      <>
        <Header
          title={`${selected.subject} · ${selected.title}`}
          sub={`Soal ${q + 1} dari ${bank.length}`}
          back={() => setScreen("taskDetail")}
        />
        <View style={styles.progress}>
          <View
            style={[
              styles.progressFill,
              { width: `${((q + 1) / bank.length) * 100}%` },
            ]}
          />
        </View>
        <Text style={styles.question}>{bank[q].q}</Text>
        {bank[q].choices.map((x, i) => (
          <Pressable
            key={x}
            onPress={() => !checked && setChoice(i)}
            style={[
              styles.choice,
              choice === i && styles.choiceSelected,
              checked && i === bank[q].answer && styles.correct,
            ]}
          >
            <Text style={styles.choiceLetter}>{"ABCD"[i]}</Text>
            <Text style={[styles.itemTitle, { flex: 1 }]}>{x}</Text>
            {checked && i === bank[q].answer ? (
              <Text style={styles.correctLabel}>Benar ✓</Text>
            ) : checked && choice === i ? (
              <Text style={styles.wrongLabel}>Salah ×</Text>
            ) : choice === i ? (
              <Text style={styles.badge}>Dipilih ✓</Text>
            ) : null}
          </Pressable>
        ))}
        <ClaySection style={styles.note}>
          <Text style={styles.noteTitle}>
            {checked
              ? choice === bank[q].answer
                ? "✓ Tepat!"
                : "Belum tepat. Tetap semangat!"
              : "💡 Petunjuk"}
          </Text>
          <Text style={styles.muted}>
            {checked
              ? `${bank[q].explain} Jawaban benar: ${bank[q].choices[bank[q].answer]}.`
              : choice === null
                ? "Pilih satu jawaban dulu."
                : `Pilihanmu: ${bank[q].choices[choice]}. Sudah yakin?`}
          </Text>
        </ClaySection>
        <Button
          title={
            checked
              ? q === bank.length - 1
                ? "Lihat hasil"
                : "Soal berikutnya"
              : "Periksa jawaban"
          }
          disabled={choice === null}
          onPress={() => (checked ? nextQuiz() : setChecked(true))}
        />
      </>
    );
  else if (screen === "result") {
    let result = data.results[selected.id];
    content = (
      <>
        <Header
          title="Hasil kuis"
          sub={`${selected.subject} · ${selected.title}${result.demo ? " · Contoh" : ""}`}
          back={() => setScreen("main")}
        />
        <View style={styles.result}>
          <Text style={{ fontSize: 45 }}>🌟</Text>
          <Text style={styles.resultNumber}>
            {result.score} / {result.total}
          </Text>
          <Text style={styles.section}>Bagus! Terus berlatih ya.</Text>
        </View>
        {result.total !== bank.length ? (
          <Text style={styles.smallMuted}>
            Rincian soal lama tidak tersedia setelah pembaruan bank soal; nilai
            tetap tersimpan.
          </Text>
        ) : (
          bank.slice(0, result.total).map((x, i) => (
            <Card key={x.q}>
              <Text style={styles.itemTitle}>
                {result.answers[i] === x.answer ? "✓" : "✕"} {i + 1}. {x.q}
              </Text>
              <Text style={styles.smallMuted}>
                Jawaban benar: {x.choices[x.answer]}
              </Text>
            </Card>
          ))
        )}
        <Text style={styles.loginNote}>
          Hasil tersimpan di perangkat ini, belum dikirim ke guru.
        </Text>
        <Button
          title="Kembali ke tugas"
          onPress={() => {
            setTaskFilter("Riwayat");
            setTab("Tugas");
            setScreen("main");
          }}
        />
      </>
    );
  } else if (screen === "essay") {
    const pair = essayBank[q];
    content = (
      <>
        <Header
          title={`${selected.subject} · Latihan`}
          sub={`Soal ${q + 1} dari ${essayBank.length} · tanpa batas waktu`}
          back={() => setScreen(teacher ? "practicePreview" : "practiceDetail")}
        />
        <View style={styles.progress}>
          <View
            style={[
              styles.progressFill,
              { width: `${((q + 1) / essayBank.length) * 100}%` },
            ]}
          />
        </View>
        <Text style={styles.question}>{pair[0]}</Text>
        <Text style={styles.label}>Jawabanmu</Text>
        <TextInput
          multiline
          textAlignVertical="top"
          style={[styles.input, { height: 140 }]}
          value={essay}
          onChangeText={setEssay}
          placeholder="Tulis jawabanmu di sini..."
        />
        {showExample && (
          <ClaySection style={styles.note}>
            <Text style={styles.noteTitle}>💡 Contoh jawaban</Text>
            <Text style={[styles.muted, { lineHeight: 22 }]}>{pair[1]}</Text>
          </ClaySection>
        )}
        <Button
          title={
            showExample
              ? q === essayBank.length - 1
                ? "Selesai latihan"
                : "Soal berikutnya"
              : "Lihat contoh jawaban"
          }
          disabled={!essay.trim()}
          onPress={() => (showExample ? nextEssay() : setShowExample(true))}
        />
        <Text style={styles.loginNote}>
          Latihan ini tidak dinilai; status selesai tercatat di perangkat ini.
        </Text>
      </>
    );
  } else if (screen === "practiceResult")
    content = (
      <>
        <Header title="Latihan selesai!" sub={selected.title} />
        <View style={styles.result}>
          <Text style={{ fontSize: 55 }}>🌱</Text>
          <Text style={styles.section}>Hebat, kamu sudah berlatih!</Text>
          <Text style={styles.muted}>
            Terus belajar sedikit demi sedikit, ya.
          </Text>
        </View>
        <Button
          title={teacher ? "Kembali ke mata pelajaran" : "Kembali ke latihan"}
          onPress={() => {
            if (teacher) {
              setScreen("subject");
            } else {
              setTab(student ? "Tugas" : "Latihan");
              setScreen("main");
            }
          }}
        />
      </>
    );
  else if (screen === "teacherTask") {
    const roster = gradeRoster(selected.className, selected);
    content = (
      <>
        <Header
          title={selected.title}
          sub={`${selected.subject} · ${selected.className}`}
          back={() => setScreen("main")}
        />
        <Card>
          <Text style={styles.itemTitle}>Durasi: {selected.minutes} menit</Text>
          <Text style={styles.muted}>
            {selected.kind === "file"
              ? `File tugas: ${selected.file?.name || "tidak tersedia"}`
              : `Soal contoh untuk ${selected.subject} · ${bank.length} soal`}
          </Text>
          {selected.kind === "file" && selected.file && (
            <Button
              title="Buka file tugas"
              onPress={() => openAttachment(selected.file)}
            />
          )}
        </Card>
        {!!error && <Text style={styles.noteTitle}>{error}</Text>}
        <Text style={styles.section}>Nilai siswa · {selected.className}</Text>
        <Text style={[styles.muted, { marginBottom: 12 }]}>
          Daftar contoh. Nilai kuis dihitung dari hasil lokal; tanda — berarti
          belum ada nilai, bukan nol.
        </Text>
        {roster.map((member) => {
          const grade = gradeFor(selected, member);
          return (
            <Item
              key={member.id}
              item={{
                icon: "🙂",
                title: member.name,
                meta:
                  gradeNote(selected, member) +
                  (member.example ? " · siswa contoh" : ""),
                color: "#e4eef7",
              }}
              status={grade === null ? "—" : String(grade)}
            />
          );
        })}
        {role === "guru" && (
          <Button
            title="Rekap nilai per kelas"
            onPress={() => openGradeRecap(selected.className, "teacherTask")}
          />
        )}
        <Button title="Kembali ke tugas" onPress={() => changeTab("Tugas")} />
      </>
    );
  } else if (screen === "gradeRecap" && role === "guru") {
    const classTasks = data.tasks.filter(
      (t) => t.className === gradeClass && t.subject === data.teacherSubject,
    );
    const rows = reportRows(gradeClass);
    content = (
      <>
        <Header
          title="Rekap nilai per kelas"
          sub={`${data.teacherSubject} · data lokal`}
          back={() => {
            setError("");
            setNotice("");
            setScreen(gradeReturn);
          }}
        />
        <Text style={styles.label}>Pilih kelas untuk wali kelas</Text>
        <Chips
          options={CLASSES}
          value={gradeClass}
          onChange={(v) => {
            setGradeClass(v);
            setError("");
            setNotice("");
          }}
        />
        <ClaySection style={styles.note}>
          <Text style={styles.noteTitle}>
            {gradeClass} · {data.teacherSubject}
          </Text>
          <Text style={styles.muted}>
            Hanya tugas dan siswa contoh kelas ini yang disertakan. Nilai kosong
            bukan nol; nilai contoh bukan nilai resmi.
          </Text>
        </ClaySection>
        <Text style={styles.section}>Ringkasan nilai</Text>
        {classTasks.length ? (
          classTasks.map((t) => (
            <Card key={t.id}>
              <Text style={styles.itemTitle}>
                {t.title}
                {t.demo ? " · contoh" : ""}
              </Text>
              {gradeRoster(gradeClass, t).map((member) => {
                const score = gradeFor(t, member);
                return (
                  <View
                    key={member.id}
                    style={{
                      flexDirection: "row",
                      justifyContent: "space-between",
                      gap: 12,
                      marginTop: 10,
                    }}
                  >
                    <View style={{ flex: 1 }}>
                      <Text style={styles.itemTitle}>{member.name}</Text>
                      <Text style={styles.smallMuted}>
                        {gradeNote(t, member)}
                        {member.example ? " · siswa contoh" : ""}
                      </Text>
                    </View>
                    <Text style={styles.noteTitle}>
                      {score === null ? "—" : score}
                    </Text>
                  </View>
                );
              })}
            </Card>
          ))
        ) : (
          <Text style={styles.muted}>
            Belum ada tugas untuk kelas dan mata pelajaran ini.
          </Text>
        )}
        <Text style={styles.section}>Ekspor dan bagikan</Text>
        <Text style={styles.muted}>
          Pilih format. Di ponsel, pilih sendiri wali kelas melalui menu
          berbagi; di web file diunduh. Belum ada pengiriman otomatis atau
          sinkronisasi antarperangkat.
        </Text>
        {!!error && <Text style={styles.noteTitle}>{error}</Text>}
        {!!notice && <Text style={styles.smallMuted}>{notice}</Text>}
        <Button
          title="Ekspor Excel (.xlsx)"
          disabled={exporting}
          onPress={() => exportGrades("Excel")}
        />
        <Button
          title="Ekspor PDF"
          disabled={exporting}
          onPress={() => exportGrades("PDF")}
        />
      </>
    );
  } else if (screen === "subject") {
    const subjectClass = filter === "Semua kelas" ? "Kelas 1" : filter;
    const subjectTasks = data.tasks.filter(
      (t) => t.subject === draftSubject && t.className === subjectClass,
    );
    const subjectPractices = allPractices.filter(
      (p) =>
        p.subject === draftSubject &&
        (!p.className || p.className === subjectClass),
    );
    content = (
      <>
        <Header
          title={draftSubject}
          sub={`${subjectClass} · Mata pelajaran`}
          back={() => setScreen("main")}
        />
        <Tabs
          options={["Tugas", "Latihan"]}
          value={subjectTab}
          onChange={setSubjectTab}
        />
        <View style={styles.sectionRow}>
          <Text style={styles.muted}>
            {subjectTab === "Tugas"
              ? `${subjectTasks.length} tugas`
              : `${subjectPractices.length} latihan`}
          </Text>
          <Pressable
            onPress={() => {
              const subject = draftSubject;
              openForm(subjectTab === "Tugas" ? "taskForm" : "practiceForm");
              setDraftSubject(subject);
              setDraftClass(
                subject === "Ilmu Pengetahuan Alam dan Sosial (IPAS)" &&
                  !subjectsForClass(subjectClass).includes(subject)
                  ? "Kelas 3"
                  : subjectClass,
              );
            }}
          >
            <Text style={styles.addBadge}>＋ Tambah</Text>
          </Pressable>
        </View>
        <View style={{ height: 12 }} />
        {subjectTab === "Tugas"
          ? subjectTasks.map((t) => (
              <Item
                key={t.id}
                item={taskItem(t)}
                onPress={() => openTask(t)}
                status={data.results[t.id] ? "Selesai" : "Aktif"}
              />
            ))
          : subjectPractices.map((p) => (
              <Item
                key={p.id}
                item={practiceItem(p)}
                onPress={() => {
                  setSelected(p);
                  setReturnScreen("subject");
                  setScreen("practicePreview");
                }}
                status="Latihan"
              />
            ))}
        {subjectTab === "Tugas" && !subjectTasks.length && (
          <Text style={styles.empty}>Belum ada tugas untuk kelas ini.</Text>
        )}
        {subjectTab === "Latihan" && !subjectPractices.length && (
          <Text style={styles.empty}>Belum ada latihan untuk kelas ini.</Text>
        )}
      </>
    );
  } else if (screen === "practicePreview")
    content = (
      <>
        <Header
          title={selected.title}
          sub={`${selected.subject} · ${selected.className || "Semua kelas"}`}
          back={() => setScreen(returnScreen)}
        />
        <ClaySection style={styles.detailIcon}>
          <Text style={{ fontSize: 48 }}>
            {subjectInfo[selected.subject].icon}
          </Text>
        </ClaySection>
        <Text style={styles.section}>Latihan esai</Text>
        <Text style={styles.muted}>
          5 soal contoh sesuai mata pelajaran. Latihan dipakai untuk belajar dan
          tidak dinilai.
        </Text>
        <Button title="Lihat latihan" onPress={practiceStart} />
      </>
    );
  else if (screen === "practiceForm")
    content = (
      <>
        <Header
          title="Tambah latihan"
          sub="Buat latihan esai untuk kelas"
          back={() => setScreen("subject")}
        />
        <Text style={styles.label}>Judul latihan</Text>
        <TextInput
          style={styles.input}
          value={draftTitle}
          onChangeText={setDraftTitle}
          placeholder="Mis. Latihan penjumlahan"
        />
        <Text style={styles.label}>Mata pelajaran</Text>
        <Chips
          options={
            role === "guru" ? [data.teacherSubject] : Object.keys(subjectInfo)
          }
          value={draftSubject}
          onChange={setDraftSubject}
        />
        <Text style={styles.label}>Untuk kelas</Text>
        <Chips
          options={
            draftSubject === "Ilmu Pengetahuan Alam dan Sosial (IPAS)"
              ? CLASSES.slice(2)
              : CLASSES
          }
          value={draftClass}
          onChange={setDraftClass}
        />
        <Text style={styles.smallMuted}>
          Instruksi asisten (demo offline): buat latihan tepat 5 soal sesuai
          mata pelajaran dan kelas. Latihan memakai bank soal contoh, bukan AI.
          Jawaban tidak dikirim. Status selesai hanya terlihat di perangkat ini.
        </Text>
        {!!error && <Text style={styles.noteTitle}>{error}</Text>}
        <Button
          title="Simpan latihan"
          onPress={() => {
            if (!draftTitle.trim()) {
              setError("Isi judul latihan.");
              return;
            }
            if (!subjectsForClass(draftClass).includes(draftSubject)) {
              setError("IPAS hanya untuk kelas 3–6.");
              return;
            }
            update({
              customPractices: [
                ...(data.customPractices || []),
                {
                  id: `p${Date.now()}`,
                  subject: draftSubject,
                  title: draftTitle.trim(),
                  className: draftClass,
                },
              ],
            });
            setFilter(draftClass);
            setSubjectTab("Latihan");
            setScreen("subject");
          }}
        />
      </>
    );
  else if (screen === "students")
    content = (
      <>
        <Header
          title="Daftar Siswa"
          sub="Data contoh"
          back={() => setScreen("main")}
        />
        {[data.studentName, "Sari Putri", "Rafi Pratama"].map((n, i) => (
          <Item
            key={n}
            item={{
              icon: i === 2 ? "👦🏻" : "🙂",
              title: n,
              meta:
                i === 0
                  ? `${Object.keys(data.results).length} tugas selesai`
                  : "Siswa aktif · Kelas 1",
              color: "#f8ebec",
            }}
            status="Aktif"
            onPress={() => {
              setSelected({
                title: n,
                body:
                  i === 0
                    ? `${Object.keys(data.results).length} tugas selesai dan ${doneCount} latihan selesai di perangkat ini.`
                    : "Data siswa contoh.",
              });
              setScreen("studentDetail");
            }}
          />
        ))}
      </>
    );
  else if (screen === "studentDetail")
    content = (
      <>
        <Header
          title={selected.title}
          sub="Profil siswa"
          back={() => setScreen("students")}
        />
        <Card>
          <Text style={styles.itemTitle}>Perkembangan belajar</Text>
          <Text style={styles.muted}>{selected.body}</Text>
        </Card>
      </>
    );
  else if (screen === "taskForm" || screen === "announcementForm") {
    let isTask = screen === "taskForm";
    content = (
      <>
        <Header
          title={isTask ? "Tambah tugas" : "Buat pengumuman"}
          sub="Data demo tersimpan di perangkat ini"
          back={() => setScreen(isTask ? "main" : "announcements")}
        />
        <Text style={styles.label}>Judul</Text>
        <TextInput
          style={styles.input}
          value={draftTitle}
          onChangeText={setDraftTitle}
          placeholder={isTask ? "Mis. Pecahan sederhana" : "Mis. Libur sekolah"}
        />
        {isTask ? (
          <>
            <Text style={styles.label}>Mata pelajaran</Text>
            <Chips
              options={
                role === "guru"
                  ? [data.teacherSubject]
                  : Object.keys(subjectInfo)
              }
              value={draftSubject}
              onChange={setDraftSubject}
            />
            <Text style={styles.label}>File tugas</Text>
            <Button
              title={attachment ? "Ganti file" : "Unggah file tugas"}
              onPress={pickAttachment}
            />
            {attachment && (
              <Text style={styles.smallMuted}>📎 {attachment.name}</Text>
            )}
            <View style={styles.note}>
              <Text style={styles.noteTitle}>
                Asisten penyusunan · demo offline
              </Text>
              <Text style={styles.muted}>
                Instruksi asisten (demo offline): buat tugas tepat 10 soal
                sesuai mata pelajaran dan kelas. Bank soal ini belum menggunakan
                AI dan tidak membaca isi PDF.
              </Text>
              <Button
                title="Gunakan kuis contoh"
                onPress={() => {
                  setAttachment(null);
                  setDraftBody("quiz");
                  if (!draftTitle.trim()) setDraftTitle(`Kuis ${draftSubject}`);
                  setNotice("Kuis contoh siap disimpan.");
                }}
              />
            </View>
            <Text style={styles.label}>Tenggat pengumpulan (YYYY-MM-DD)</Text>
            <TextInput
              style={styles.input}
              value={draftDue}
              onChangeText={setDraftDue}
              placeholder="2026-12-31"
              autoCapitalize="none"
            />
            <Text style={styles.smallMuted}>
              Hitung mundur memakai akhir hari pada zona waktu perangkat; waktu
              tidak mengunci tugas di demo.
            </Text>
            <Text style={[styles.label, { marginTop: 12 }]}>
              Durasi pengerjaan (menit)
            </Text>
            <TextInput
              style={styles.input}
              value={draftMinutes}
              onChangeText={setDraftMinutes}
              keyboardType="numeric"
            />
            <Text style={styles.smallMuted}>
              File tersimpan lokal. Kuis contoh berisi 10 soal. Batas waktu
              belum menghitung mundur.
            </Text>
          </>
        ) : (
          <>
            <Text style={styles.label}>Isi pengumuman</Text>
            <TextInput
              multiline
              textAlignVertical="top"
              style={[styles.input, { height: 120 }]}
              value={draftBody}
              onChangeText={setDraftBody}
              placeholder="Tulis pengumuman..."
            />
          </>
        )}
        <Text style={[styles.label, { marginTop: 14 }]}>Untuk kelas</Text>
        <Chips
          options={
            wali
              ? [WALI_CLASS]
              : isTask
                ? draftSubject === "Ilmu Pengetahuan Alam dan Sosial (IPAS)"
                  ? CLASSES.slice(2)
                  : CLASSES
                : ["Semua kelas", ...CLASSES]
          }
          value={draftClass}
          onChange={setDraftClass}
        />
        {!!error && <Text style={styles.noteTitle}>{error}</Text>}
        <Button
          title={isTask ? "Simpan tugas" : "Kirim pengumuman"}
          onPress={isTask ? saveTask : saveAnnouncement}
        />
        {!!notice && <Text style={styles.smallMuted}>{notice}</Text>}
      </>
    );
  } else if (screen === "progress")
    content = (
      <>
        <Header
          title="Perjalanan belajar"
          sub={`${data.studentName} · ${data.childClass}`}
          back={() => setScreen("main")}
        />
        <ClaySection style={styles.progressHero}>
          <Text style={{ fontSize: 44 }}>🌟</Text>
          <Text style={styles.progressHeadline}>
            {Object.keys(data.results).length + doneCount} bintang belajar
          </Text>
          <Text style={styles.muted}>
            Satu bintang untuk setiap tugas atau latihan yang selesai. Hebat!
          </Text>
        </ClaySection>
        <View style={styles.stats}>
          <Stat
            icon="checkmark-circle"
            label="Tugas selesai"
            value={String(Object.keys(data.results).length)}
            desc="Terus semangat"
            color={C.blue}
            onPress={() => {
              setTab("Tugas");
              setTaskFilter("Riwayat");
              setScreen("main");
            }}
          />
          <Stat
            icon="grid"
            label="Latihan selesai"
            value={String(doneCount)}
            desc="Ayo berlatih"
            color={C.pink}
            onPress={() => changeTab("Latihan")}
          />
        </View>
        <Text style={styles.section}>Bagaimana perasaanmu hari ini?</Text>
        <Text style={styles.muted}>
          Pilih satu untuk bercerita. Jawaban hanya tersimpan di perangkat ini.
        </Text>
        <View style={styles.moodRow}>
          {[
            ["😊", "Senang"],
            ["😌", "Tenang"],
            ["😴", "Lelah"],
            ["😔", "Sedih"],
          ].map(([emoji, label]) => (
            <Pressable
              key={label}
              onPress={() => update({ mood: label })}
              style={[
                styles.moodOption,
                data.mood === label && styles.moodSelected,
              ]}
            >
              <Text style={{ fontSize: 27 }}>{emoji}</Text>
              <Text style={styles.smallMuted}>{label}</Text>
            </Pressable>
          ))}
        </View>
        {data.mood && (
          <ClaySection style={styles.note}>
            <Text style={styles.noteTitle}>
              Terima kasih sudah bercerita 💗
            </Text>
            <Text style={styles.muted}>
              {data.mood === "Sedih" || data.mood === "Lelah"
                ? "Tidak apa-apa beristirahat dan bercerita kepada orang dewasa yang kamu percaya."
                : "Semoga harimu menyenangkan. Yuk, belajar bersama!"}
            </Text>
          </ClaySection>
        )}
        <Button title="Mulai latihan" onPress={() => changeTab("Latihan")} />
      </>
    );
  else if (screen === "setting")
    content = (
      <>
        <Header title={setting} back={() => setScreen("main")} />
        {setting === "Informasi pribadi" ? (
          <>
            <Text style={styles.label}>Nama</Text>
            <TextInput
              style={styles.input}
              value={draftTitle}
              onChangeText={setDraftTitle}
            />
            {!teacher && (
              <>
                <Text style={styles.label}>Kelas anak</Text>
                <Chips
                  options={student ? STUDENT_CLASSES : PARENT_CLASSES}
                  value={data.childClass}
                  onChange={(v) =>
                    update(
                      student
                        ? { childClass: v, studentClass: v }
                        : { childClass: v, parentClass: v },
                    )
                  }
                />
                <Text style={styles.smallMuted}>
                  {student
                    ? "Siswa hanya dapat memilih kelas 5 atau 6."
                    : "Orang tua mendampingi anak kelas 1 sampai 4."}
                </Text>
                <Text style={styles.label}>Agama siswa (opsional)</Text>
                <Chips
                  options={religions}
                  value={data.religion}
                  onChange={(v) => update({ religion: v })}
                />
                <Text style={styles.smallMuted}>
                  Contoh agama disesuaikan pilihan ini. Konten lain masih umum
                  dan perlu ditinjau guru.
                </Text>
              </>
            )}
            {!!error && <Text style={styles.noteTitle}>{error}</Text>}
            <Button
              title="Simpan perubahan"
              onPress={() => {
                if (!draftTitle.trim()) {
                  setError("Nama tidak boleh kosong.");
                  return;
                }
                update(
                  wali
                    ? { waliName: draftTitle.trim() }
                    : teacher
                      ? { teacherName: draftTitle.trim() }
                      : { studentName: draftTitle.trim() },
                );
                setError("");
                setScreen("main");
              }}
            />
          </>
        ) : setting === "Mata pelajaran" ? (
          <>
            <Text style={styles.muted}>
              Pilih mata pelajaran guru demo. Tugas akan disaring sesuai pilihan
              ini.
            </Text>
            <Chips
              options={Object.keys(subjectInfo)}
              value={data.teacherSubject}
              onChange={(v) => update({ teacherSubject: v })}
            />
            <Button title="Selesai" onPress={() => setScreen("main")} />
          </>
        ) : setting === "Tampilan" ? (
          <Card style={styles.setting}>
            <View style={{ flex: 1 }}>
              <Text style={styles.itemTitle}>Mode gelap</Text>
              <Text style={styles.smallMuted}>
                Berlaku untuk semua peran di perangkat ini.
              </Text>
            </View>
            <Switch
              value={themeDark}
              onValueChange={(v) => update({ darkMode: v })}
              trackColor={{ true: C.rose }}
            />
          </Card>
        ) : setting === "Privasi dan keamanan" ? (
          <Card>
            <Text style={styles.itemTitle}>Privasi pada aplikasi demo</Text>
            <Text style={[styles.muted, { marginTop: 8 }]}>
              Data, hasil belajar, dan akun demo disimpan di perangkat ini.
              Belum ada sinkronisasi, autentikasi aman, atau pengiriman data ke
              guru.
            </Text>
          </Card>
        ) : setting === "Notifikasi" ? (
          <Card style={styles.setting}>
            <View style={{ flex: 1 }}>
              <Text style={styles.itemTitle}>Notifikasi aplikasi</Text>
              <Text style={styles.smallMuted}>
                Tampilkan lencana notifikasi pada perangkat ini
              </Text>
            </View>
            <Switch
              value={data.notifications}
              onValueChange={(v) => update({ notifications: v })}
              trackColor={{ true: C.rose }}
            />
          </Card>
        ) : (
          <Card>
            <Text style={styles.itemTitle}>Tentang KARSA</Text>
            <Text style={[styles.muted, { marginTop: 8 }]}>
              KARSA adalah prototipe pembelajaran. Pilih tugas untuk mengerjakan
              kuis atau latihan untuk menjawab soal esai. Data tersimpan di
              perangkat ini dan belum disinkronkan.
            </Text>
          </Card>
        )}
      </>
    );
  const isSheet = screen === "taskDetail" || screen === "practiceDetail";
  const nav = wali
    ? ["Beranda", "Anggota", "Rekap", "Agenda", "Profil"]
    : teacher
      ? ["Beranda", "Kelas", "Tugas", "Kalender", "Profil"]
      : student
        ? ["Beranda", "Tugas", "Profil"]
        : ["Beranda", "Tugas", "Latihan", "Profil"];
  const icons = {
    Beranda: "home",
    Anggota: "people",
    Rekap: "bar-chart",
    Agenda: "calendar",
    Kelas: "people",
    Tugas: "checkmark-circle",
    Kalender: "calendar",
    Latihan: "grid",
    Profil: "person",
  };
  return (
    <ThemeContext.Provider value={{ styles, C }}>
      <MotionContext.Provider value={reduceMotion}>
        <SafeAreaView
          style={[
            styles.safe,
            screen === "splash" && { backgroundColor: "#b4def8" },
          ]}
        >
          <StatusBar
            barStyle={
              themeDark && screen !== "splash"
                ? "light-content"
                : "dark-content"
            }
          />
          <View style={styles.shell}>
            {Platform.OS === "web" && screen !== "splash" && (
              <View style={styles.topline}>
                <Text style={styles.time}>9:41</Text>
                <Text style={styles.topdots}>●●●</Text>
              </View>
            )}
            {screen === "splash" ? (
              <SplashScreen ready={loaded} onFinish={finishSplash} />
            ) : (
              <ScrollView
                key={isSheet ? "main" + tab : screen + tab}
                keyboardShouldPersistTaps="handled"
                contentContainerStyle={
                  screen === "login" ? styles.loginScroll : styles.content
                }
              >
                <MotionSection key={isSheet ? "main" + tab : screen + tab}>
                  {storageError && (
                    <View style={styles.note}>
                      <Text style={styles.noteTitle}>
                        Penyimpanan lokal gagal. Perubahan mungkin tidak
                        tersimpan; periksa ruang perangkat.
                      </Text>
                    </View>
                  )}
                  {isSheet
                    ? screen === "taskDetail" || student
                      ? tasks()
                      : practiceList()
                    : content}
                </MotionSection>
              </ScrollView>
            )}
            {(screen === "main" || isSheet) && (
              <View style={styles.nav}>
                {nav.map((n) => (
                  <Pressable
                    accessibilityRole="button"
                    key={n}
                    onPress={() => changeTab(n)}
                    style={styles.navItem}
                  >
                    <Icon
                      name={icons[n]}
                      size={23}
                      color={tab === n ? C.rose : "#a8b6bf"}
                    />
                    <Text
                      style={[
                        styles.navText,
                        tab === n && { color: C.rose, fontWeight: "700" },
                      ]}
                    >
                      {n}
                    </Text>
                  </Pressable>
                ))}
              </View>
            )}
            <Modal
              visible={isSheet}
              transparent
              animationType="slide"
              onRequestClose={() => setScreen("main")}
            >
              <View style={styles.sheetBackdrop}>
                <Pressable
                  style={{ flex: 1 }}
                  accessibilityLabel="Tutup"
                  onPress={() => setScreen("main")}
                />
                <View style={styles.sheet}>
                  <View style={styles.sheetHandle} />
                  <ScrollView keyboardShouldPersistTaps="handled">
                    {isSheet && content}
                  </ScrollView>
                </View>
              </View>
            </Modal>
          </View>
        </SafeAreaView>
      </MotionContext.Provider>
    </ThemeContext.Provider>
  );
}
const lightStyles = StyleSheet.create({
  welcomeTop: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginTop: 16,
    marginBottom: 20,
  },
  schoolIdentity: {
    ...clay.soft,
    flexDirection: "row",
    alignItems: "center",
    gap: 10,
    backgroundColor: C.card,
    borderRadius: 18,
    paddingVertical: 8,
    paddingHorizontal: 11,
    marginBottom: 18,
  },
  schoolIdentityCompact: { marginBottom: 5, paddingVertical: 6 },
  schoolLogoFrame: {
    width: 38,
    height: 38,
    borderRadius: 12,
    backgroundColor: "#fff",
    alignItems: "center",
    justifyContent: "center",
  },
  schoolLogo: { width: 33, height: 33 },
  schoolName: {
    color: C.ink,
    fontWeight: "900",
    letterSpacing: 0.65,
    fontSize: 10,
  },
  schoolCaption: { color: C.muted, fontSize: 10, marginTop: 2 },
  waliHero: {
    ...clay.soft,
    backgroundColor: "#f9ebee",
    borderRadius: 24,
    padding: 18,
    marginBottom: 14,
  },
  waliHeroTitle: {
    color: C.ink,
    fontWeight: "900",
    fontSize: 20,
    marginBottom: 8,
  },
  waliQuickLink: {
    ...clay.soft,
    backgroundColor: C.card,
    borderRadius: 20,
    padding: 16,
    marginTop: 5,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
  },
  chartRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: 9,
    marginTop: 13,
  },
  chartLabel: { width: 58, color: C.ink, fontSize: 12, fontWeight: "700" },
  chartTrack: {
    flex: 1,
    height: 10,
    borderRadius: 8,
    backgroundColor: "#f3e7e6",
    overflow: "hidden",
  },
  chartFill: { height: 10, borderRadius: 8 },
  chartNumber: {
    width: 30,
    textAlign: "right",
    color: C.ink,
    fontWeight: "800",
    fontSize: 12,
  },
  attendanceOptions: { flexDirection: "row", gap: 6, marginTop: 12 },
  attendanceChip: {
    flex: 1,
    backgroundColor: "#f7eeed",
    borderRadius: 12,
    paddingVertical: 9,
    alignItems: "center",
  },
  attendanceChipActive: { backgroundColor: C.rose },
  attendanceText: { fontSize: 11, color: C.ink, fontWeight: "700" },
  studentHero: {
    ...clay.soft,
    backgroundColor: "#f9e5e9",
    minHeight: 160,
    borderRadius: 26,
    marginBottom: 14,
    overflow: "hidden",
    flexDirection: "row",
    alignItems: "center",
    padding: 20,
  },
  heroCloudOne: {
    position: "absolute",
    width: 135,
    height: 135,
    borderRadius: 68,
    backgroundColor: "#fceef0",
    right: -30,
    top: -42,
  },
  heroCloudTwo: {
    position: "absolute",
    width: 100,
    height: 100,
    borderRadius: 50,
    backgroundColor: "#e4eff7",
    right: 12,
    bottom: -60,
  },
  heroCopy: { flex: 1, zIndex: 1 },
  heroEyebrow: {
    color: C.rose,
    letterSpacing: 1.2,
    fontSize: 9,
    fontWeight: "800",
    marginBottom: 8,
  },
  heroTitle: {
    fontSize: 25,
    lineHeight: 29,
    color: C.ink,
    fontWeight: "900",
    marginBottom: 7,
  },
  heroText: { fontSize: 11, lineHeight: 16, color: "#71899b", maxWidth: 205 },
  heroArt: {
    width: 92,
    height: 92,
    borderRadius: 32,
    backgroundColor: "#fdf8f5",
    alignItems: "center",
    justifyContent: "center",
    ...clay.soft,
  },
  heroEmoji: { fontSize: 44 },
  heroStar: { position: "absolute", right: -7, top: -8, fontSize: 23 },
  missionCard: {
    ...clay.soft,
    backgroundColor: "#fffdfb",
    borderRadius: 23,
    padding: 15,
    marginBottom: 14,
  },
  missionTop: { flexDirection: "row", alignItems: "center", gap: 10 },
  missionIcon: {
    ...clay.soft,
    width: 42,
    height: 42,
    borderRadius: 14,
    backgroundColor: "#f9e8ec",
    justifyContent: "center",
    alignItems: "center",
  },
  missionCount: { fontSize: 14, fontWeight: "900", color: C.rose },
  missionTrack: {
    height: 8,
    borderRadius: 8,
    backgroundColor: "#f3e8e6",
    overflow: "hidden",
    marginTop: 12,
    marginBottom: 7,
  },
  missionFill: { height: 8, borderRadius: 8, backgroundColor: C.pink },
  tipCard: {
    ...clay.soft,
    backgroundColor: "#eef5f9",
    borderRadius: 22,
    padding: 14,
    marginTop: 10,
    marginBottom: 16,
    flexDirection: "row",
    alignItems: "center",
    gap: 12,
  },
  tipIcon: {
    ...clay.soft,
    backgroundColor: "#fff6e5",
    width: 45,
    height: 45,
    borderRadius: 15,
    alignItems: "center",
    justifyContent: "center",
  },
  classReferenceHero: {
    ...clay.soft,
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: "#e5f0f8",
    borderRadius: 22,
    padding: 20,
    marginBottom: 12,
    minHeight: 130,
  },
  tilesGrid: {
    flexDirection: "row",
    flexWrap: "wrap",
    justifyContent: "space-between",
    marginBottom: 12,
  },
  classTile: {
    ...clay.soft,
    width: "48.5%",
    padding: 17,
    minHeight: 100,
    borderRadius: 23,
    marginBottom: 14,
    justifyContent: "center",
  },
  tileLabel: { color: C.ink, fontSize: 12 },
  tileNumber: { color: C.ink, fontSize: 25, fontWeight: "800" },
  studentWelcome: {
    ...clay.soft,
    backgroundColor: "#f9ebee",
    borderRadius: 20,
    padding: 18,
    marginBottom: 12,
  },
  loginScroll: { flexGrow: 1, paddingBottom: 0 },
  loginPage: {
    flex: 1,
    backgroundColor: C.card,
    overflow: "hidden",
    paddingBottom: 38,
  },
  loginHero: {
    ...clay.soft,
    height: 250,
    backgroundColor: "#f9e8e9",
    alignItems: "center",
    justifyContent: "center",
    overflow: "hidden",
    borderBottomLeftRadius: 55,
    borderBottomRightRadius: 55,
  },
  loginCirclePink: {
    position: "absolute",
    width: 160,
    height: 160,
    borderRadius: 80,
    right: -60,
    top: -55,
    backgroundColor: "#f8dbe2",
  },
  loginCircleBlue: {
    position: "absolute",
    width: 130,
    height: 130,
    borderRadius: 65,
    left: -60,
    bottom: 12,
    backgroundColor: "#dcebf6",
  },
  loginBack: {
    ...clay.soft,
    position: "absolute",
    top: 18,
    left: 20,
    width: 46,
    height: 46,
    borderRadius: 23,
    backgroundColor: "white",
    alignItems: "center",
    justifyContent: "center",
    zIndex: 2,
  },
  loginLogo: { width: 195, height: 185 },
  loginBody: { paddingHorizontal: 24, paddingTop: 22, zIndex: 1 },
  loginTitle: {
    textAlign: "center",
    fontSize: 27,
    lineHeight: 34,
    color: C.ink,
    fontWeight: "800",
  },
  loginSubtitle: {
    textAlign: "center",
    fontSize: 12,
    color: C.muted,
    marginTop: 7,
    marginBottom: 20,
  },
  loginField: {
    ...clay.inset,
    height: 56,
    flexDirection: "row",
    alignItems: "center",
    gap: 14,
    borderWidth: 1,
    borderColor: "#e8ddd7",
    borderRadius: 17,
    backgroundColor: "#fff",
    paddingHorizontal: 16,
    marginBottom: 13,
  },
  loginInput: { flex: 1, height: "100%", fontSize: 15, color: C.ink },
  forgotLink: { alignItems: "flex-end", paddingVertical: 8 },
  loginButton: {
    ...clay.raised,
    height: 58,
    borderRadius: 18,
    backgroundColor: C.rose,
    alignItems: "center",
    justifyContent: "center",
    marginTop: 12,
    shadowColor: C.rose,
    shadowOpacity: 0.22,
    shadowOffset: { width: 0, height: 8 },
    shadowRadius: 10,
    elevation: 4,
  },
  loginButtonText: { fontSize: 18, color: "white", fontWeight: "800" },
  loginWavePink: {
    position: "absolute",
    bottom: -45,
    left: -40,
    right: -40,
    height: 90,
    borderRadius: 100,
    backgroundColor: "#f8dce5",
  },
  loginWaveBlue: {
    position: "absolute",
    bottom: -70,
    left: -35,
    right: -35,
    height: 100,
    borderRadius: 100,
    backgroundColor: "#e0edf8",
  },
  addBadge: {
    color: "white",
    backgroundColor: C.rose,
    overflow: "hidden",
    borderRadius: 16,
    paddingVertical: 7,
    paddingHorizontal: 13,
    fontWeight: "700",
    fontSize: 12,
  },
  correctLabel: { color: "#408c67", fontWeight: "700", fontSize: 11 },
  wrongLabel: { color: "#b93643", fontWeight: "700", fontSize: 11 },
  sheetBackdrop: {
    flex: 1,
    justifyContent: "flex-end",
    backgroundColor: "rgba(24,42,58,0.38)",
  },
  sheet: {
    ...clay.soft,
    maxHeight: "85%",
    backgroundColor: C.bg,
    borderTopLeftRadius: 28,
    borderTopRightRadius: 28,
    paddingHorizontal: 20,
    paddingBottom: 28,
  },
  sheetHandle: {
    width: 38,
    height: 4,
    borderRadius: 3,
    backgroundColor: "#d8c9c5",
    alignSelf: "center",
    marginTop: 10,
  },
  splashStage: {
    flex: 1,
    backgroundColor: "#a2d7fb",
    overflow: "hidden",
    justifyContent: "flex-end",
  },
  splashIllustration: {
    width: "100%",
    aspectRatio: 654 / 1048,
    maxHeight: "100%",
    alignSelf: "center",
  },
  splashImage: { width: "100%", height: "100%" },
  loadingArea: {
    ...clay.soft,
    position: "absolute",
    bottom: 20,
    alignSelf: "center",
    alignItems: "center",
    backgroundColor: "rgba(255,250,247,0.9)",
    borderRadius: 24,
    paddingHorizontal: 18,
    paddingVertical: 9,
  },
  loadingDots: { flexDirection: "row", gap: 7, marginBottom: 4 },
  loadingDot: {
    width: 7,
    height: 7,
    borderRadius: 4,
    backgroundColor: "#c8526d",
  },
  loadingText: {
    fontSize: 10,
    fontWeight: "700",
    color: "#6b7f8a",
    letterSpacing: 0.2,
  },
  splashArtwork: {
    flex: 1,
    width: "100%",
    minHeight: 500,
    backgroundColor: "#b4def8",
  },
  progressCard: {
    ...clay.soft,
    flexDirection: "row",
    alignItems: "center",
    gap: 12,
    backgroundColor: "#f8edf0",
    padding: 16,
    marginTop: 3,
  },
  progressHero: {
    ...clay.soft,
    alignItems: "center",
    backgroundColor: "#f9edf0",
    borderRadius: 22,
    padding: 24,
    marginBottom: 14,
  },
  progressHeadline: {
    fontSize: 22,
    fontWeight: "800",
    color: C.ink,
    marginVertical: 10,
  },
  moodRow: { flexDirection: "row", gap: 8, marginTop: 16, marginBottom: 10 },
  moodOption: {
    ...clay.soft,
    flex: 1,
    alignItems: "center",
    paddingVertical: 12,
    backgroundColor: "white",
    borderRadius: 16,
    borderWidth: 1,
    borderColor: C.line,
  },
  moodSelected: { borderColor: C.rose, backgroundColor: "#fbeaec" },
  demoAccount: {
    ...clay.soft,
    backgroundColor: "#f2f6f8",
    borderWidth: 1,
    borderColor: "#dce9ee",
    borderRadius: 16,
    padding: 16,
    marginTop: 22,
    gap: 4,
  },
  splashContent: { flexGrow: 1, paddingHorizontal: 0, paddingBottom: 0 },
  splashScreen: {
    flex: 1,
    minHeight: 500,
    backgroundColor: "#fffaf7",
    alignItems: "center",
    justifyContent: "center",
  },
  splashLogoWrap: {
    shadowColor: "#b1445d",
    shadowOpacity: 0.18,
    shadowRadius: 25,
    shadowOffset: { width: 0, height: 12 },
    elevation: 8,
    backgroundColor: "#fffaf7",
    borderRadius: 36,
  },
  splashLogo: { width: 132, height: 132, borderRadius: 32 },
  splashName: {
    fontSize: 38,
    fontWeight: "900",
    letterSpacing: 7,
    color: C.ink,
    marginTop: 25,
    marginLeft: 7,
  },
  splashTagline: { fontSize: 14, color: C.muted, marginTop: 8 },
  splashFooter: { position: "absolute", bottom: 45 },
  splashFooterText: {
    fontSize: 9,
    fontWeight: "700",
    letterSpacing: 1.4,
    color: "#c6a9ae",
  },
  safe: { flex: 1, backgroundColor: "#f4ede9", alignItems: "center" },
  shell: {
    flex: 1,
    width: "100%",
    maxWidth: 480,
    backgroundColor: C.bg,
    overflow: "hidden",
  },
  topline: {
    height: 40,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    paddingHorizontal: 24,
  },
  time: { fontWeight: "700", fontSize: 12, color: C.ink },
  topdots: { color: C.ink, letterSpacing: -2 },
  content: { paddingHorizontal: 20, paddingBottom: 30, flexGrow: 1 },
  greeting: {
    flexDirection: "row",
    alignItems: "center",
    gap: 12,
    marginVertical: 12,
  },
  avatar: {
    ...clay.soft,
    width: 52,
    height: 52,
    borderRadius: 26,
    backgroundColor: "#f0e0e5",
    alignItems: "center",
    justifyContent: "center",
  },
  name: { fontSize: 20, fontWeight: "800", color: C.ink },
  muted: { fontSize: 13, color: C.muted, lineHeight: 19 },
  smallMuted: { fontSize: 11, color: C.muted, lineHeight: 16 },
  bell: {
    ...clay.soft,
    width: 42,
    height: 42,
    borderRadius: 21,
    borderWidth: 1,
    borderColor: C.line,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: C.card,
  },
  dot: {
    position: "absolute",
    right: -3,
    top: -4,
    backgroundColor: C.pink,
    borderRadius: 10,
    width: 18,
    height: 18,
    alignItems: "center",
    justifyContent: "center",
  },
  dotText: { color: "white", fontSize: 10, fontWeight: "bold" },
  banner: { width: "100%", height: 125, borderRadius: 22, marginBottom: 12 },
  chip: {
    ...clay.soft,
    borderRadius: 24,
    paddingVertical: 9,
    paddingHorizontal: 16,
    marginRight: 7,
    backgroundColor: C.card,
  },
  chipActive: { backgroundColor: C.rose, borderColor: C.rose },
  chipText: { color: C.muted, fontSize: 12, fontWeight: "700" },
  stats: { flexDirection: "row", gap: 10 },
  card: {
    ...clay.soft,
    backgroundColor: C.card,
    borderRadius: 23,
    padding: 15,
    marginBottom: 12,
  },
  stat: {
    flex: 1,
    flexDirection: "row",
    alignItems: "center",
    gap: 10,
    minHeight: 90,
  },
  statIcon: {
    ...clay.raised,
    height: 40,
    width: 40,
    borderRadius: 20,
    alignItems: "center",
    justifyContent: "center",
  },
  statNumber: { fontSize: 23, color: C.ink, fontWeight: "800" },
  sectionRow: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginTop: 8,
  },
  section: { fontSize: 18, fontWeight: "800", color: C.ink, marginBottom: 10 },
  link: { color: C.rose, fontWeight: "700", fontSize: 12 },
  item: { flexDirection: "row", alignItems: "center", gap: 12, minHeight: 76 },
  itemIcon: {
    ...clay.soft,
    height: 46,
    width: 46,
    borderRadius: 14,
    alignItems: "center",
    justifyContent: "center",
  },
  itemTitle: { fontSize: 14, fontWeight: "700", color: C.ink, lineHeight: 20 },
  badge: {
    color: C.rose,
    backgroundColor: "#f9e8ed",
    overflow: "hidden",
    borderRadius: 12,
    paddingHorizontal: 9,
    paddingVertical: 5,
    fontSize: 10,
    fontWeight: "700",
  },
  nav: {
    ...clay.soft,
    height: 76,
    borderTopWidth: 2,
    borderColor: "#ffffff",
    backgroundColor: "#fffaf8",
    borderTopLeftRadius: 25,
    borderTopRightRadius: 25,
    flexDirection: "row",
    justifyContent: "space-around",
  },
  navItem: { flex: 1, alignItems: "center", justifyContent: "center", gap: 4 },
  navText: { fontSize: 10, color: C.muted },
  pageHeader: {
    flexDirection: "row",
    alignItems: "center",
    marginTop: 15,
    marginBottom: 24,
  },
  back: { marginRight: 10, padding: 4 },
  title: { fontSize: 24, fontWeight: "800", color: C.ink, marginBottom: 4 },
  segment: {
    ...clay.inset,
    flexDirection: "row",
    backgroundColor: "#f5ecea",
    borderRadius: 20,
    padding: 4,
    marginBottom: 18,
  },
  segmentItem: { flex: 1, alignItems: "center", padding: 12 },
  segmentActive: { ...clay.soft, backgroundColor: "#fffdfb", borderRadius: 16 },
  segmentText: { color: C.muted, fontWeight: "700" },
  note: {
    ...clay.soft,
    backgroundColor: "#fff1e8",
    borderRadius: 18,
    padding: 16,
    marginVertical: 14,
  },
  noteTitle: { color: C.rose, fontWeight: "800", marginBottom: 5 },
  overline: {
    color: C.rose,
    fontWeight: "800",
    fontSize: 10,
    letterSpacing: 1,
    marginVertical: 10,
  },
  empty: { color: C.muted, textAlign: "center", marginTop: 35 },
  classHero: {
    ...clay.soft,
    backgroundColor: "#f9e6e7",
    borderRadius: 22,
    padding: 22,
    marginBottom: 14,
  },
  classTitle: {
    fontSize: 24,
    color: C.ink,
    fontWeight: "800",
    marginVertical: 5,
  },
  calendarHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: 12,
  },
  grid: { flexDirection: "row", flexWrap: "wrap", marginBottom: 24 },
  dayLabel: {
    width: "14.28%",
    textAlign: "center",
    color: C.muted,
    fontSize: 12,
    paddingVertical: 10,
  },
  day: {
    width: "14.28%",
    textAlign: "center",
    color: C.ink,
    paddingVertical: 12,
  },
  today: {
    backgroundColor: C.rose,
    color: "white",
    overflow: "hidden",
    borderRadius: 20,
  },
  profileHero: { alignItems: "center", paddingVertical: 22 },
  bigAvatar: {
    ...clay.soft,
    width: 84,
    height: 84,
    borderRadius: 42,
    backgroundColor: "#f4e4e7",
    alignItems: "center",
    justifyContent: "center",
    marginBottom: 12,
  },
  profileBadge: {
    color: C.rose,
    backgroundColor: "#f9e6ea",
    overflow: "hidden",
    padding: 7,
    borderRadius: 20,
    fontSize: 11,
    marginTop: 10,
  },
  setting: { flexDirection: "row", alignItems: "center" },
  logout: { alignItems: "center", padding: 20 },
  welcome: { flex: 1 },
  brand: {
    color: C.rose,
    fontWeight: "900",
    letterSpacing: 2,
    marginTop: 20,
    marginBottom: 42,
  },
  welcomeTitle: {
    fontSize: 22,
    fontWeight: "800",
    color: C.ink,
    marginBottom: 8,
  },
  role: {
    ...clay.soft,
    flexDirection: "row",
    alignItems: "center",
    borderRadius: 23,
    padding: 14,
    gap: 12,
    marginTop: 18,
    minHeight: 90,
  },
  roleAvatar: {
    ...clay.soft,
    width: 54,
    height: 54,
    borderRadius: 27,
    backgroundColor: "white",
    alignItems: "center",
    justifyContent: "center",
  },
  quote: {
    textAlign: "center",
    color: "#385d76",
    fontSize: 20,
    fontStyle: "italic",
    fontWeight: "700",
    lineHeight: 30,
    marginTop: 55,
  },
  demo: {
    textAlign: "center",
    color: "#c8aab0",
    fontSize: 10,
    letterSpacing: 1.5,
    marginTop: 50,
  },
  loginIcon: { alignItems: "center", padding: 45 },
  label: { fontSize: 13, fontWeight: "700", color: C.ink, marginBottom: 8 },
  input: {
    ...clay.inset,
    borderWidth: 1,
    borderColor: C.line,
    backgroundColor: "white",
    borderRadius: 14,
    padding: 15,
    fontSize: 14,
    color: C.ink,
    marginBottom: 18,
  },
  button: {
    ...clay.raised,
    backgroundColor: C.rose,
    borderRadius: 20,
    alignItems: "center",
    padding: 16,
    marginTop: 12,
  },
  buttonText: { color: "white", fontWeight: "800", fontSize: 14 },
  loginNote: {
    textAlign: "center",
    color: C.muted,
    fontSize: 12,
    marginTop: 18,
  },
  detailIcon: {
    ...clay.soft,
    height: 150,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "#f9e9eb",
    borderRadius: 24,
    marginBottom: 25,
  },
  question: {
    fontSize: 22,
    fontWeight: "800",
    color: C.ink,
    lineHeight: 32,
    marginVertical: 25,
  },
  progress: { height: 7, backgroundColor: "#f1e4e1", borderRadius: 10 },
  progressFill: { height: 7, backgroundColor: C.rose, borderRadius: 10 },
  choice: {
    ...clay.soft,
    flexDirection: "row",
    alignItems: "center",
    gap: 16,
    backgroundColor: "white",
    borderWidth: 2,
    borderColor: "#fff",
    borderRadius: 19,
    padding: 12,
    marginBottom: 10,
  },
  choiceSelected: { borderColor: C.rose, backgroundColor: "#fff2f4" },
  correct: { borderColor: "#7cba99", backgroundColor: "#edf8f1" },
  choiceLetter: {
    width: 32,
    height: 32,
    textAlign: "center",
    textAlignVertical: "center",
    paddingTop: 7,
    borderRadius: 10,
    backgroundColor: "#f4efed",
    color: C.ink,
    fontWeight: "800",
  },
  result: {
    ...clay.soft,
    backgroundColor: "#fffdfb",
    borderRadius: 26,
    marginBottom: 16,
    alignItems: "center",
    padding: 45,
  },
  resultNumber: {
    fontSize: 52,
    fontWeight: "900",
    color: C.rose,
    marginVertical: 15,
  },
});
// Recolor surface and text properties while preserving all layout and the warm rose/blue accents.
function makeDarkStyle(style) {
  const output = { ...style };
  const toRgb = (value) => {
    if (typeof value !== "string") return null;
    if (value === "white") return [255, 255, 255];
    if (value === "black") return [0, 0, 0];
    let h = value.match(/^#([0-9a-f]{3}|[0-9a-f]{6})$/i);
    if (!h) return null;
    let v =
      h[1].length === 3
        ? h[1]
            .split("")
            .map((x) => x + x)
            .join("")
        : h[1];
    return [0, 2, 4].map((i) => parseInt(v.slice(i, i + 2), 16));
  };
  for (const key of [
    "backgroundColor",
    "color",
    "borderColor",
    "borderTopColor",
    "shadowColor",
  ]) {
    if (
      key.startsWith("border") &&
      typeof output[key] === "string" &&
      output[key].startsWith("rgba(255,")
    ) {
      output[key] = "#554a54";
      continue;
    }
    const color = toRgb(output[key]);
    if (!color) continue;
    const lum = (color[0] * 0.299 + color[1] * 0.587 + color[2] * 0.114) / 255;
    if (key === "backgroundColor" && lum > 0.72) {
      output[key] =
        color[2] > color[0] + 4
          ? "#34414e"
          : color[0] > color[1] + 6
            ? "#493640"
            : "#332d36";
    } else if (key === "color" && lum < 0.68) {
      output[key] = color[0] > color[1] * 1.15 ? "#f2a9bc" : "#eee7ed";
    } else if (key.startsWith("border") && lum > 0.65) output[key] = "#554a54";
    else if (key === "shadowColor") output[key] = "#08070a";
  }
  if (output.boxShadow)
    output.boxShadow =
      "0 7px 15px rgba(0,0,0,0.27), inset 0 2px 3px rgba(255,255,255,0.06)";
  return output;
}
const darkStyles = StyleSheet.create(
  Object.fromEntries(
    Object.entries(lightStyles).map(([key, value]) => [
      key,
      makeDarkStyle(value),
    ]),
  ),
);

export default App;
