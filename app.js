const STORAGE_KEY = "svatebni-koordinace-pwa-v2";
const WEDDING_DATE_KEY = "svatebni-koordinace-wedding-date";
const BUDGET_KEY = "svatebni-koordinace-budget";

const DEFAULT_TASKS = [
  { id: "budget", title: "Stanovit celkový rozpočet", category: "Plánování", description: "Ujasněte si rozpočet na hostinu, oblečení, dekorace, hudbu i rezervy.", notes: "", done: false },
  { id: "date", title: "Vybrat datum svatby", category: "Plánování", description: "Zvolte termín, který sedí vám, rodině i dostupnosti dodavatelů.", notes: "", done: false },
  { id: "venue", title: "Zarezervovat místo obřadu a hostiny", category: "Místo", description: "Potvrďte lokaci, čas i počet hostů, které místo zvládne.", notes: "", done: false },
  { id: "guests", title: "Připravit seznam hostů", category: "Hosté", description: "Sepište hosty a průběžně sledujte potvrzení účasti.", notes: "", done: false },
  { id: "invitations", title: "Objednat nebo vytvořit pozvánky", category: "Hosté", description: "Připravte text, design a plán rozeslání pozvánek.", notes: "", done: false },
  { id: "attire-bride", title: "Vybrat svatební šaty", category: "Oblečení", description: "Domluvte zkoušky, úpravy a termín vyzvednutí šatů.", notes: "", done: false },
  { id: "attire-groom", title: "Vybrat oblek a doplňky", category: "Oblečení", description: "Vyřešte oblek, košili, boty i sladění s celkovým stylem svatby.", notes: "", done: false },
  { id: "rings", title: "Vybrat a objednat prstýnky", category: "Oblečení", description: "Ověřte velikosti, gravírování a termín dodání.", notes: "", done: false },
  { id: "officiant", title: "Domluvit oddávajícího a dokumenty", category: "Formality", description: "Zkontrolujte všechny potřebné doklady a termíny na úřadě.", notes: "", done: false },
  { id: "flowers", title: "Objednat květiny a výzdobu", category: "Dekorace", description: "Domluvte kytici, korsáže, slavobránu a dekorace stolu.", notes: "", done: false },
  { id: "music", title: "Zajistit hudbu nebo DJ", category: "Program", description: "Potvrďte playlist, ozvučení a harmonogram dne.", notes: "", done: false },
  { id: "photographer", title: "Rezervovat fotografa nebo kameramana", category: "Program", description: "Upřesněte styl focení, seznam momentů a časový plán.", notes: "", done: false },
  { id: "cake", title: "Objednat svatební dort", category: "Hostina", description: "Vyberte chuť, design, velikost a čas dovezení.", notes: "", done: false },
  { id: "menu", title: "Doladit menu a nápoje", category: "Hostina", description: "Vyřešte hlavní chod, vegetariánské varianty, dětské porce i pitný režim.", notes: "", done: false },
  { id: "seating", title: "Připravit zasedací pořádek", category: "Hosté", description: "Rozmyslete stoly, vztahy mezi hosty a usazení rodiny.", notes: "", done: false },
  { id: "transport", title: "Zajistit dopravu", category: "Logistika", description: "Domluvte auto pro novomanžele, případně dopravu hostů.", notes: "", done: false },
  { id: "accommodation", title: "Vyřešit ubytování pro hosty", category: "Logistika", description: "Potvrďte pokoje, počty lidí a instrukce k příjezdu.", notes: "", done: false },
  { id: "timeline", title: "Sepsat harmonogram svatebního dne", category: "Program", description: "Udělejte jasný plán od příprav až po večerní zábavu.", notes: "", done: false },
  { id: "vows", title: "Připravit slib nebo řeč", category: "Program", description: "Sepište osobní slova, pokud chcete mít vlastní slib.", notes: "", done: false },
  { id: "emergency", title: "Nachystat svatební pohotovostní balíček", category: "Logistika", description: "Připravte lepicí náplasti, jehlu, nit, kapesníčky, kosmetiku a další jistoty.", notes: "", done: false }
];

const state = {
  tasks: loadTasks(),
  selectedId: null,
  filters: { category: "Všechny kategorie", status: "all" },
  weddingDate: loadWeddingDate(),
  budget: loadBudget()
};

const els = {
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
  newDescription: document.querySelector("#newDescription"),
  overallProgress: document.querySelector("#overallProgress"),
  overallBar: document.querySelector("#overallBar"),
  toggleSelectedButton: document.querySelector("#toggleSelectedButton"),
  scrollToAddButton: document.querySelector("#scrollToAddButton"),
  addTaskSection: document.querySelector("#addTaskSection"),
  taskItemTemplate: document.querySelector("#taskItemTemplate"),
  weddingDateInput: document.querySelector("#weddingDateInput"),
  weddingDateButton: document.querySelector("#weddingDateButton"),
  weddingDateDisplay: document.querySelector("#weddingDateDisplay"),
  countdownHeadline: document.querySelector("#countdownHeadline"),
  countdownText: document.querySelector("#countdownText"),
  countdownDays: document.querySelector("#countdownDays"),
  budgetForm: document.querySelector("#budgetForm"),
  budgetTotalInput: document.querySelector("#budgetTotalInput"),
  budgetSpentInput: document.querySelector("#budgetSpentInput"),
  budgetTotalDisplay: document.querySelector("#budgetTotalDisplay"),
  budgetSpentSummary: document.querySelector("#budgetSpentSummary"),
  budgetRemainingDisplay: document.querySelector("#budgetRemainingDisplay"),
  budgetStatusText: document.querySelector("#budgetStatusText")
};

init();

function init() {
  if (!state.selectedId && state.tasks.length) state.selectedId = state.tasks[0].id;
  fillFilterOptions();
  bindEvents();
  render();
  registerServiceWorker();
}

function loadTasks() {
  const saved = localStorage.getItem(STORAGE_KEY);
  if (!saved) return structuredClone(DEFAULT_TASKS);

  try {
    return JSON.parse(saved).map((task) => ({
      id: task.id || crypto.randomUUID(),
      title: task.title || "Bez názvu",
      category: task.category || "Vlastní",
      description: task.description || "Vlastní úkol doplněný do svatební koordinace.",
      notes: task.notes || "",
      done: Boolean(task.done)
    }));
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
  if (state.weddingDate) localStorage.setItem(WEDDING_DATE_KEY, state.weddingDate);
  else localStorage.removeItem(WEDDING_DATE_KEY);
}

function loadBudget() {
  const saved = localStorage.getItem(BUDGET_KEY);
  if (!saved) return { total: 0, spent: 0 };

  try {
    const parsed = JSON.parse(saved);
    return {
      total: normalizeMoney(parsed.total),
      spent: normalizeMoney(parsed.spent)
    };
  } catch {
    return { total: 0, spent: 0 };
  }
}

function saveBudget() {
  localStorage.setItem(BUDGET_KEY, JSON.stringify(state.budget));
}

function bindEvents() {
  els.categoryFilter.addEventListener("change", () => {
    state.filters.category = els.categoryFilter.value;
    renderTaskList();
  });

  els.statusFilter.addEventListener("change", () => {
    state.filters.status = els.statusFilter.value;
    renderTaskList();
  });

  els.resetFiltersButton.addEventListener("click", () => {
    state.filters = { category: "Všechny kategorie", status: "all" };
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
      description: els.newDescription.value.trim() || "Vlastní úkol doplněný do svatební koordinace.",
      notes: "",
      done: false
    });

    state.selectedId = state.tasks[0].id;
    els.taskForm.reset();
    saveTasks();
    fillFilterOptions();
    render();
  });

  els.scrollToAddButton.addEventListener("click", () => {
    els.addTaskSection.scrollIntoView({ behavior: "smooth", block: "start" });
  });

  els.weddingDateButton.addEventListener("click", openDatePicker);
  els.weddingDateDisplay.addEventListener("click", openDatePicker);

  els.weddingDateInput.addEventListener("change", () => {
    state.weddingDate = els.weddingDateInput.value;
    saveWeddingDate();
    renderCountdown();
  });

  els.budgetForm.addEventListener("submit", (event) => {
    event.preventDefault();
    state.budget.total = normalizeMoney(els.budgetTotalInput.value);
    state.budget.spent = normalizeMoney(els.budgetSpentInput.value);
    saveBudget();
    renderBudget();
  });
}

function fillFilterOptions() {
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

function render() {
  renderTaskList();
  renderDetail();
  renderStats();
  renderCountdown();
  renderBudget();
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
    item.querySelector(".task-item__meta").textContent = task.category;
    toggleButton.textContent = task.done ? "Vrátit" : "Hotovo";

    mainButton.addEventListener("click", () => {
      state.selectedId = task.id;
      render();
    });

    toggleButton.addEventListener("click", () => {
      task.done = !task.done;
      saveTasks();
      render();
    });

    fragment.append(item);
  });

  els.taskList.replaceChildren(fragment);
  els.taskCountText.textContent = `${filteredTasks.length} ${pluralizeItems(filteredTasks.length)}`;
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
  els.detailMeta.textContent = task.category;
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
}

function renderCountdown() {
  els.weddingDateInput.value = state.weddingDate;

  if (!state.weddingDate) {
    els.countdownHeadline.textContent = "Vyberte datum svého dne";
    els.countdownText.textContent = "Jakmile nastavíte termín, aplikace začne automaticky odpočítávat zbývající dny.";
    els.countdownDays.textContent = "--";
    els.weddingDateDisplay.textContent = "Vyberte termín";
    els.weddingDateDisplay.dataset.empty = "true";
    return;
  }

  const today = new Date();
  const now = new Date(today.getFullYear(), today.getMonth(), today.getDate());
  const [year, month, day] = state.weddingDate.split("-").map(Number);
  const weddingDate = new Date(year, month - 1, day);
  const diffMs = weddingDate.getTime() - now.getTime();
  const diffDays = Math.ceil(diffMs / 86400000);
  const formattedDate = weddingDate.toLocaleDateString("cs-CZ", {
    day: "numeric",
    month: "long",
    year: "numeric"
  });

  els.weddingDateDisplay.textContent = formattedDate;
  els.weddingDateDisplay.dataset.empty = "false";

  if (diffDays > 0) {
    els.countdownHeadline.textContent = `Do svatby zbývá ${formatUnit(diffDays, "den", "dny", "dní")}`;
    els.countdownText.textContent = `Velký den připadá na ${formattedDate} a odpočet běží přesně podle nastaveného termínu.`;
  } else if (diffDays === 0) {
    els.countdownHeadline.textContent = "Svatební den je právě dnes";
    els.countdownText.textContent = `Dnes je ${formattedDate}. Užijte si svůj den naplno a bez stresu.`;
  } else {
    const elapsed = Math.abs(diffDays);
    els.countdownHeadline.textContent = `Od svatby uplynulo ${formatUnit(elapsed, "den", "dny", "dní")}`;
    els.countdownText.textContent = `Svatební den proběhl ${formattedDate}. Koordinace vám může zůstat jako vzpomínka na přípravy.`;
  }

  els.countdownDays.textContent = String(Math.abs(diffDays));
}

function renderBudget() {
  const total = state.budget.total;
  const spent = state.budget.spent;
  const remaining = total - spent;

  els.budgetTotalInput.value = total || "";
  els.budgetSpentInput.value = spent || "";
  els.budgetTotalDisplay.textContent = formatCurrency(total);
  els.budgetSpentSummary.textContent = `Utraceno ${formatCurrency(spent)}`;
  els.budgetRemainingDisplay.textContent = formatCurrency(remaining);

  if (!total) {
    els.budgetStatusText.textContent = "Zadejte rozpočet a průběžné výdaje.";
  } else if (remaining >= 0) {
    els.budgetStatusText.textContent = `V rozpočtu vám zbývá ${formatCurrency(remaining)}.`;
  } else {
    els.budgetStatusText.textContent = `Rozpočet je překročen o ${formatCurrency(Math.abs(remaining))}.`;
  }
}

function getFilteredTasks() {
  return state.tasks.filter((task) => {
    const categoryMatch = state.filters.category === "Všechny kategorie" || task.category === state.filters.category;
    const statusMatch = state.filters.status === "all" || (state.filters.status === "done" && task.done) || (state.filters.status === "open" && !task.done);
    return categoryMatch && statusMatch;
  });
}

function getSelectedTask() {
  return state.tasks.find((task) => task.id === state.selectedId) ?? null;
}

function registerServiceWorker() {
  if ("serviceWorker" in navigator) {
    window.addEventListener("load", () => {
      navigator.serviceWorker.register("./service-worker.js").catch(() => {});
    });
  }
}

function openDatePicker() {
  if (typeof els.weddingDateInput.showPicker === "function") {
    els.weddingDateInput.showPicker();
  } else {
    els.weddingDateInput.click();
  }
}

function normalizeMoney(value) {
  const number = Number(value);
  return Number.isFinite(number) && number > 0 ? Math.round(number) : 0;
}

function formatCurrency(value) {
  return new Intl.NumberFormat("cs-CZ", {
    style: "currency",
    currency: "CZK",
    maximumFractionDigits: 0
  }).format(value);
}

function pluralizeItems(value) {
  if (value === 1) return "položka";
  if (value >= 2 && value <= 4) return "položky";
  return "položek";
}

function formatUnit(value, one, few, many) {
  const mod10 = value % 10;
  const mod100 = value % 100;

  if (mod10 === 1 && mod100 !== 11) return `${value} ${one}`;
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return `${value} ${few}`;
  return `${value} ${many}`;
}
