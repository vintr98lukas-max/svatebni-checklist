const STORAGE_KEY = "svatebni-checklist-pwa-v1";
const WEDDING_DATE_KEY = "svatebni-checklist-wedding-date";

const DEFAULT_TASKS = [
  { id: "budget", title: "Stanovit celkový rozpočet", category: "Plánování", owner: "Společně", description: "Ujasněte si rozpočet na hostinu, oblečení, dekorace, hudbu i rezervy.", notes: "", done: false },
  { id: "date", title: "Vybrat datum svatby", category: "Plánování", owner: "Společně", description: "Zvolte termín, který sedí vám, rodině i dostupnosti dodavatelů.", notes: "", done: false },
  { id: "venue", title: "Zarezervovat místo obřadu a hostiny", category: "Místo", owner: "Společně", description: "Potvrďte lokaci, čas i počet hostů, které místo zvládne.", notes: "", done: false },
  { id: "guests", title: "Připravit seznam hostů", category: "Hosté", owner: "Společně", description: "Sepište hosty a průběžně sledujte potvrzení účasti.", notes: "", done: false },
  { id: "invitations", title: "Objednat nebo vytvořit pozvánky", category: "Hosté", owner: "Nevěsta", description: "Připravte text, design a plán rozeslání pozvánek.", notes: "", done: false },
  { id: "attire-bride", title: "Vybrat svatební šaty", category: "Oblečení", owner: "Nevěsta", description: "Domluvte zkoušky, úpravy a termín vyzvednutí šatů.", notes: "", done: false },
  { id: "attire-groom", title: "Vybrat oblek a doplňky", category: "Oblečení", owner: "Ženich", description: "Vyřešit oblek, košili, boty i sladění s celkovým stylem svatby.", notes: "", done: false },
  { id: "rings", title: "Vybrat a objednat prstýnky", category: "Oblečení", owner: "Společně", description: "Ověřte velikosti, gravírování a termín dodání.", notes: "", done: false },
  { id: "officiant", title: "Domluvit oddávajícího a dokumenty", category: "Formality", owner: "Společně", description: "Zkontrolujte všechny potřebné doklady a termíny na úřadě.", notes: "", done: false },
  { id: "flowers", title: "Objednat květiny a výzdobu", category: "Dekorace", owner: "Nevěsta", description: "Domluvte kytici, korsáže, slavobránu a dekorace stolu.", notes: "", done: false },
  { id: "music", title: "Zajistit hudbu nebo DJ", category: "Program", owner: "Ženich", description: "Potvrďte playlist, ozvučení a harmonogram dne.", notes: "", done: false },
  { id: "photographer", title: "Rezervovat fotografa nebo kameramana", category: "Program", owner: "Společně", description: "Upřesněte styl focení, seznam momentů a časový plán.", notes: "", done: false },
  { id: "cake", title: "Objednat svatební dort", category: "Hostina", owner: "Společně", description: "Vyberte chuť, design, velikost a čas dovezení.", notes: "", done: false },
  { id: "menu", title: "Doladit menu a nápoje", category: "Hostina", owner: "Společně", description: "Vyřešit hlavní chod, vegetariány, dětské porce i pitný režim.", notes: "", done: false },
  { id: "seating", title: "Připravit zasedací pořádek", category: "Hosté", owner: "Společně", description: "Rozmyslete stoly, vztahy mezi hosty a usazení rodiny.", notes: "", done: false },
  { id: "transport", title: "Zajistit dopravu", category: "Logistika", owner: "Ženich", description: "Domluvte auto pro novomanžele, případně dopravu hostů.", notes: "", done: false },
  { id: "accommodation", title: "Vyřešit ubytování pro hosty", category: "Logistika", owner: "Společně", description: "Potvrďte pokoje, počty lidí a instrukce k příjezdu.", notes: "", done: false },
  { id: "timeline", title: "Sepsat harmonogram svatebního dne", category: "Program", owner: "Společně", description: "Udělejte jasný plán od příprav až po večerní zábavu.", notes: "", done: false },
  { id: "vows", title: "Připravit slib nebo řeč", category: "Program", owner: "Nevěsta", description: "Sepište osobní slova, pokud chcete mít vlastní slib.", notes: "", done: false },
  { id: "emergency", title: "Nachystat svatební pohotovostní balíček", category: "Logistika", owner: "Nevěsta", description: "Lepicí náplasti, jehlu, nit, kapesníčky, kosmetiku a další jistoty.", notes: "", done: false }
];

const state = {
  tasks: loadTasks(),
  selectedId: null,
  filters: { owner: "Všichni", category: "Všechny kategorie", status: "all" },
  weddingDate: loadWeddingDate()
};

const els = {
  ownerFilter: document.querySelector("#ownerFilter"),
  categoryFilter: document.querySelector("#categoryFilter"),
  statusFilter: document.querySelector("#statusFilter"),
  resetFiltersButton: document.querySelector("#resetFiltersButton"),
  taskList: document.querySelector("#taskList"),
  taskCountText: document.querySelector("#taskCountText"),
  detailTitle: document.querySelector("#detailTitle"),
  detailMeta: document.querySelector("#detailMeta"),
  detailDescription: document.querySelector("#detailDescription"),
  selectedStatus: document.querySelector("#selectedStatus"),
  notesInput: document.querySelector("#notesInput"),
  saveNotesButton: document.querySelector("#saveNotesButton"),
  deleteTaskButton: document.querySelector("#deleteTaskButton"),
  taskForm: document.querySelector("#taskForm"),
  newTitle: document.querySelector("#newTitle"),
  newCategory: document.querySelector("#newCategory"),
  newOwner: document.querySelector("#newOwner"),
  newDescription: document.querySelector("#newDescription"),
  overallProgress: document.querySelector("#overallProgress"),
  overallBar: document.querySelector("#overallBar"),
  brideProgress: document.querySelector("#brideProgress"),
  brideSummary: document.querySelector("#brideSummary"),
  groomProgress: document.querySelector("#groomProgress"),
  groomSummary: document.querySelector("#groomSummary"),
  toggleSelectedButton: document.querySelector("#toggleSelectedButton"),
  scrollToAddButton: document.querySelector("#scrollToAddButton"),
  addTaskSection: document.querySelector("#addTaskSection"),
  installCard: document.querySelector("#installCard"),
  installButton: document.querySelector("#installButton"),
  installText: document.querySelector("#installText"),
  taskItemTemplate: document.querySelector("#taskItemTemplate"),
  weddingDateInput: document.querySelector("#weddingDateInput"),
  countdownHeadline: document.querySelector("#countdownHeadline"),
  countdownText: document.querySelector("#countdownText"),
  countdownDays: document.querySelector("#countdownDays"),
  countdownWeeks: document.querySelector("#countdownWeeks")
};

let deferredPrompt = null;

init();

function init() {
  if (!state.selectedId && state.tasks.length) state.selectedId = state.tasks[0].id;
  fillFilterOptions();
  bindEvents();
  render();
  registerServiceWorker();
  setupInstallPrompt();
}

function loadTasks() {
  const saved = localStorage.getItem(STORAGE_KEY);
  if (!saved) return structuredClone(DEFAULT_TASKS);
  try {
    return JSON.parse(saved).map((task) => ({ ...task, id: task.id || crypto.randomUUID() }));
  } catch {
    return structuredClone(DEFAULT_TASKS);
  }
}

function saveTasks() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(state.tasks));
}

function loadWeddingDate() {
  const saved = localStorage.getItem(WEDDING_DATE_KEY);
  return saved && /^\d{4}-\d{2}-\d{2}$/.test(saved) ? saved : "";
}

function saveWeddingDate() {
  if (state.weddingDate) {
    localStorage.setItem(WEDDING_DATE_KEY, state.weddingDate);
    return;
  }

  localStorage.removeItem(WEDDING_DATE_KEY);
}

function fillFilterOptions() {
  fillSelect(els.ownerFilter, ["Všichni", "Nevěsta", "Ženich", "Společně"], state.filters.owner);
  fillSelect(els.categoryFilter, ["Všechny kategorie", ...new Set(state.tasks.map((task) => task.category))], state.filters.category);
  els.statusFilter.value = state.filters.status;
}

function fillSelect(select, values, selectedValue) {
  select.innerHTML = "";
  values.forEach((value) => {
    const option = document.createElement("option");
    option.value = value;
    option.textContent = value;
    option.selected = value === selectedValue;
    select.append(option);
  });
}

function bindEvents() {
  els.ownerFilter.addEventListener("change", () => { state.filters.owner = els.ownerFilter.value; renderTaskList(); });
  els.categoryFilter.addEventListener("change", () => { state.filters.category = els.categoryFilter.value; renderTaskList(); });
  els.statusFilter.addEventListener("change", () => { state.filters.status = els.statusFilter.value; renderTaskList(); });

  els.resetFiltersButton.addEventListener("click", () => {
    state.filters = { owner: "Všichni", category: "Všechny kategorie", status: "all" };
    fillFilterOptions();
    renderTaskList();
  });

  els.toggleSelectedButton.addEventListener("click", () => {
    const task = getSelectedTask();
    if (!task) return;
    task.done = !task.done;
    saveTasks();
    render();
  });

  els.saveNotesButton.addEventListener("click", () => {
    const task = getSelectedTask();
    if (!task) return;
    task.notes = els.notesInput.value.trim();
    saveTasks();
    renderDetail();
  });

  els.deleteTaskButton.addEventListener("click", () => {
    const task = getSelectedTask();
    if (!task) return;
    if (!window.confirm(`Opravdu chcete smazat úkol "${task.title}"?`)) return;
    state.tasks = state.tasks.filter((item) => item.id !== task.id);
    state.selectedId = state.tasks[0]?.id ?? null;
    saveTasks();
    fillFilterOptions();
    render();
  });

  els.taskForm.addEventListener("submit", (event) => {
    event.preventDefault();
    const title = els.newTitle.value.trim();
    if (!title) return;
    state.tasks.unshift({
      id: crypto.randomUUID(),
      title,
      category: els.newCategory.value.trim() || "Vlastní",
      owner: els.newOwner.value,
      description: els.newDescription.value.trim() || "Vlastní úkol doplněný do svatebního checklistu.",
      notes: "",
      done: false
    });
    state.selectedId = state.tasks[0].id;
    els.taskForm.reset();
    els.newOwner.value = "Společně";
    saveTasks();
    fillFilterOptions();
    render();
  });

  els.scrollToAddButton.addEventListener("click", () => {
    els.addTaskSection.scrollIntoView({ behavior: "smooth", block: "start" });
  });

  els.installButton.addEventListener("click", async () => {
    if (!deferredPrompt) return;
    deferredPrompt.prompt();
    await deferredPrompt.userChoice;
    deferredPrompt = null;
    els.installCard.hidden = true;
  });

  els.weddingDateInput.addEventListener("change", () => {
    state.weddingDate = els.weddingDateInput.value;
    saveWeddingDate();
    renderCountdown();
  });
}

function render() {
  renderTaskList();
  renderDetail();
  renderStats();
  renderCountdown();
}

function renderTaskList() {
  const filteredTasks = getFilteredTasks();
  if (!filteredTasks.length) {
    const empty = document.createElement("div");
    empty.className = "empty-state";
    empty.textContent = "Tomuto filtru teď neodpovídá žádný úkol.";
    els.taskList.replaceChildren(empty);
    els.taskCountText.textContent = "0 položek";
    return;
  }

  const fragment = document.createDocumentFragment();
  filteredTasks.forEach((task) => {
    const item = els.taskItemTemplate.content.firstElementChild.cloneNode(true);
    const mainButton = item.querySelector(".task-item__main");
    const toggleButton = item.querySelector(".task-item__toggle");
    item.classList.toggle("task-item--done", task.done);
    mainButton.classList.toggle("is-selected", task.id === state.selectedId);
    item.querySelector(".task-item__title").textContent = task.title;
    item.querySelector(".task-item__meta").textContent = `${task.owner} • ${task.category}`;
    toggleButton.textContent = task.done ? "Vrátit" : "Hotovo";
    mainButton.addEventListener("click", () => { state.selectedId = task.id; render(); });
    toggleButton.addEventListener("click", () => { task.done = !task.done; saveTasks(); render(); });
    fragment.append(item);
  });

  els.taskList.replaceChildren(fragment);
  els.taskCountText.textContent = `${filteredTasks.length} ${filteredTasks.length === 1 ? "položka" : filteredTasks.length < 5 ? "položky" : "položek"}`;
}

function renderDetail() {
  const task = getSelectedTask();
  if (!task) {
    els.detailTitle.textContent = "Vyberte úkol ze seznamu";
    els.detailMeta.textContent = "";
    els.detailDescription.textContent = "Tady se zobrazí popis a poznámky k vybranému úkolu.";
    els.selectedStatus.textContent = "Bez výběru";
    els.notesInput.value = "";
    return;
  }

  els.detailTitle.textContent = task.title;
  els.detailMeta.textContent = `${task.owner} • ${task.category}`;
  els.detailDescription.textContent = task.description;
  els.selectedStatus.textContent = task.done ? "Hotovo" : "Rozpracováno";
  els.notesInput.value = task.notes || "";
}

function renderStats() {
  const total = state.tasks.length;
  const done = state.tasks.filter((task) => task.done).length;
  const overallPercent = total ? Math.round((done / total) * 100) : 0;
  els.overallProgress.textContent = `${done} z ${total}`;
  els.overallBar.style.width = `${overallPercent}%`;
  renderOwnerStats("Nevěsta", els.brideProgress, els.brideSummary);
  renderOwnerStats("Ženich", els.groomProgress, els.groomSummary);
}

function renderOwnerStats(owner, progressEl, summaryEl) {
  const relevant = state.tasks.filter((task) => task.owner === owner || task.owner === "Společně");
  const done = relevant.filter((task) => task.done).length;
  const percent = relevant.length ? Math.round((done / relevant.length) * 100) : 0;
  progressEl.textContent = `${percent} %`;
  summaryEl.textContent = `${done} z ${relevant.length} úkolů`;
}

function getFilteredTasks() {
  return state.tasks.filter((task) => {
    const ownerMatch = state.filters.owner === "Všichni" || task.owner === state.filters.owner;
    const categoryMatch = state.filters.category === "Všechny kategorie" || task.category === state.filters.category;
    const statusMatch = state.filters.status === "all" || (state.filters.status === "done" && task.done) || (state.filters.status === "open" && !task.done);
    return ownerMatch && categoryMatch && statusMatch;
  });
}

function getSelectedTask() {
  return state.tasks.find((task) => task.id === state.selectedId) ?? null;
}

function renderCountdown() {
  els.weddingDateInput.value = state.weddingDate;

  if (!state.weddingDate) {
    els.countdownHeadline.textContent = "Zadejte termín svého dne";
    els.countdownText.textContent = "Jakmile vyberete datum, aplikace začne okamžitě odpočítávat dny do svatby.";
    els.countdownDays.textContent = "--";
    els.countdownWeeks.textContent = "--";
    return;
  }

  const today = new Date();
  const now = new Date(today.getFullYear(), today.getMonth(), today.getDate());
  const [year, month, day] = state.weddingDate.split("-").map(Number);
  const weddingDate = new Date(year, month - 1, day);
  const diffMs = weddingDate.getTime() - now.getTime();
  const diffDays = Math.ceil(diffMs / 86400000);
  const diffWeeks = diffDays >= 0 ? Math.floor(diffDays / 7) : Math.ceil(diffDays / 7);
  const formattedDate = weddingDate.toLocaleDateString("cs-CZ", {
    day: "numeric",
    month: "long",
    year: "numeric"
  });

  if (diffDays > 0) {
    els.countdownHeadline.textContent = `Do svatby zbývá ${formatUnit(diffDays, "den", "dny", "dní")}`;
    els.countdownText.textContent = `Velký den připadá na ${formattedDate}. Každý splněný úkol vás teď posouvá o krok blíž.`;
  } else if (diffDays === 0) {
    els.countdownHeadline.textContent = "Svatební den je právě dnes";
    els.countdownText.textContent = `Dnes je ${formattedDate}. Užijte si svůj den naplno a bez stresu.`;
  } else {
    const elapsed = Math.abs(diffDays);
    els.countdownHeadline.textContent = `Od svatby uplynulo ${formatUnit(elapsed, "den", "dny", "dní")}`;
    els.countdownText.textContent = `Svatební den proběhl ${formattedDate}. Checklist vám může zůstat jako milá vzpomínka na přípravy.`;
  }

  els.countdownDays.textContent = String(Math.abs(diffDays));
  els.countdownWeeks.textContent = String(Math.abs(diffWeeks));
}

function formatUnit(value, one, few, many) {
  const mod10 = value % 10;
  const mod100 = value % 100;

  if (mod10 === 1 && mod100 !== 11) return `${value} ${one}`;
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return `${value} ${few}`;
  return `${value} ${many}`;
}

function registerServiceWorker() {
  if ("serviceWorker" in navigator) {
    window.addEventListener("load", () => {
      navigator.serviceWorker.register("./service-worker.js").catch(() => {});
    });
  }
}

function setupInstallPrompt() {
  const isIos = /iphone|ipad|ipod/i.test(navigator.userAgent);
  const isInStandalone = window.matchMedia("(display-mode: standalone)").matches || window.navigator.standalone;
  const isSecure = window.isSecureContext;

  if (isIos && !isInStandalone) {
    els.installCard.hidden = false;
    els.installButton.hidden = true;
    els.installText.textContent = isSecure
      ? "Na iPhonu Apple nepovoluje vlastní instalační tlačítko. Otevřete stránku v Safari, klepněte na Sdílet a zvolte „Přidat na plochu“. Po prvním načtení pak může checklist fungovat i offline."
      : "Na iPhonu je pro instalaci a offline režim potřeba HTTPS. Jakmile aplikaci otevřete přes zabezpečenou adresu v Safari, použijte Sdílet a „Přidat na plochu“.";
    return;
  }

  if (!isSecure && location.hostname !== "localhost" && location.hostname !== "127.0.0.1") {
    els.installCard.hidden = false;
    els.installButton.hidden = true;
    els.installText.textContent = "Instalace i offline režim vyžadují zabezpečené HTTPS připojení. Otevřete aplikaci přes HTTPS nebo ji nasaďte například na Vercel.";
    return;
  }

  window.addEventListener("beforeinstallprompt", (event) => {
    event.preventDefault();
    deferredPrompt = event;
    els.installCard.hidden = false;
    els.installButton.hidden = false;
    els.installText.textContent = "Nainstalujte si aplikaci na plochu a používejte ji i offline.";
  });
}
