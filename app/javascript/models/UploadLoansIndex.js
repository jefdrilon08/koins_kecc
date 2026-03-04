// app/javascript/models/UploadLoansIndex.js

import * as bootstrap from "bootstrap";

// ── DOM References ────────────────────────────────────────────────────────────
var $btnOpenUploadModal;
var $loanFileInput;
var $dropZone;
var $btnClearFile;
var $fileSelectedInfo;
var $fileNameDisplay;
var $fileSizeDisplay;
var $btnPreview;
var $btnToAmort;
var $btnToConfirm;
var $btnSave;
var $btnBack;
var $uploadSpinner;
var $previewAlert;
var $previewAlertList;
var $previewTableTbody;
var $amortSettingsTbody;
var $amortDetailPanel;
var $amortPanelHeading;
var $amortDetailTbody;
var $btnSaveAmortDetail;
var $btnResetAmortDetail;
var $btnCloseAmortPanel;
var $globalFirstPayment;
var $globalTermOverride;
var $confirmTotal;
var $confirmValid;
var $confirmCustomAmort;
var $confirmTableTbody;
var $uploadModal;
var $resultModal;
var $resultModalTitle;
var $resultSuccess;
var $resultSuccessMsg;
var $resultError;
var $resultErrorTbody;
var $btnUploadMore;
var $btnDownloadTemplate;
var $uploadLoansTbody;
var $uploadLoansEmptyRow;

// ── State ─────────────────────────────────────────────────────────────────────
var state = {
  step:               1,
  file:               null,
  previewLoans:       [],
  amortOverrides:     {},
  globalFirstPayment: null,
  globalTerm:         null,
  editingRow:         null
};

// ── Helpers ───────────────────────────────────────────────────────────────────
var csrfToken = function() {
  var meta = document.querySelector('meta[name="csrf-token"]');
  return meta ? meta.content : "";
};

var currency = function(val) {
  var n = parseFloat(val);
  return isNaN(n) ? "—" : n.toLocaleString("en-PH", { minimumFractionDigits: 2, maximumFractionDigits: 2 });
};

var formatBytes = function(b) {
  if (b < 1024)    return b + " B";
  if (b < 1048576) return (b / 1024).toFixed(1) + " KB";
  return (b / 1048576).toFixed(1) + " MB";
};

var estimateMaturity = function(startDate, n, term) {
  if (!startDate || !n) return "—";
  var d = new Date(startDate);
  n = parseInt(n) - 1;
  if (term === "weekly")            d.setDate(d.getDate() + 7 * n);
  else if (term === "monthly")      d.setMonth(d.getMonth() + n);
  else if (term === "semi-monthly") d.setDate(d.getDate() + 15 * n);
  return d.toISOString().slice(0, 10);
};

var computeSchedule = function(principal, mir, n, term, startDate) {
  principal = parseFloat(principal) || 0;
  mir       = parseFloat(mir) || 0.013;
  n         = parseInt(n) || 0;
  if (n <= 0 || principal <= 0) return [];

  var perPrincipal = +(principal / n).toFixed(2);
  var perInterest  = +(principal * mir).toFixed(2);
  var amountDue    = +(perPrincipal + perInterest).toFixed(2);
  var schedule     = [];
  var cur          = startDate ? new Date(startDate) : null;

  for (var i = 0; i < n; i++) {
    var dueDate = null;
    if (cur) {
      dueDate = cur.toISOString().slice(0, 10);
      var next = new Date(cur);
      if (term === "weekly")            next.setDate(next.getDate() + 7);
      else if (term === "monthly")      next.setMonth(next.getMonth() + 1);
      else if (term === "semi-monthly") next.setDate(next.getDate() + 15);
      cur = next;
    }
    schedule.push({ installment: i + 1, due_date: dueDate, principal: perPrincipal, interest: perInterest, amount_due: amountDue });
  }
  return schedule;
};

// ── DOM Cache ─────────────────────────────────────────────────────────────────
var _cacheDom = function() {
  $btnOpenUploadModal  = document.getElementById("btn-open-upload-modal");
  $loanFileInput       = document.getElementById("loan-file-input");
  $dropZone            = document.getElementById("upload-dropzone");
  $btnClearFile        = document.getElementById("btn-clear-file");
  $fileSelectedInfo    = document.getElementById("file-selected-info");
  $fileNameDisplay     = document.getElementById("file-name-display");
  $fileSizeDisplay     = document.getElementById("file-size-display");
  $btnPreview          = document.getElementById("btn-preview");
  $btnToAmort          = document.getElementById("btn-to-amort");
  $btnToConfirm        = document.getElementById("btn-to-confirm");
  $btnSave             = document.getElementById("btn-save-upload");
  $btnBack             = document.getElementById("btn-step-back");
  $uploadSpinner       = document.getElementById("upload-spinner");
  $previewAlert        = document.getElementById("preview-alert");
  $previewAlertList    = document.getElementById("preview-alert-list");
  $previewTableTbody   = document.getElementById("preview-table-tbody");
  $amortSettingsTbody  = document.getElementById("amort-settings-tbody");
  $amortDetailPanel    = document.getElementById("amort-detail-panel");
  $amortPanelHeading   = document.getElementById("amort-panel-heading");
  $amortDetailTbody    = document.getElementById("amort-detail-tbody");
  $btnSaveAmortDetail  = document.getElementById("btn-save-amort-detail");
  $btnResetAmortDetail = document.getElementById("btn-reset-amort-detail");
  $btnCloseAmortPanel  = document.getElementById("btn-close-amort-panel");
  $globalFirstPayment  = document.getElementById("global-first-payment");
  $globalTermOverride  = document.getElementById("global-term-override");
  $confirmTotal        = document.getElementById("confirm-total");
  $confirmValid        = document.getElementById("confirm-valid");
  $confirmCustomAmort  = document.getElementById("confirm-custom-amort");
  $confirmTableTbody   = document.getElementById("confirm-table-tbody");
  $uploadModal         = document.getElementById("upload-modal");
  $resultModal         = document.getElementById("result-modal");
  $resultModalTitle    = document.getElementById("result-modal-title");
  $resultSuccess       = document.getElementById("result-success");
  $resultSuccessMsg    = document.getElementById("result-success-msg");
  $resultError         = document.getElementById("result-error");
  $resultErrorTbody    = document.getElementById("result-error-tbody");
  $btnUploadMore       = document.getElementById("btn-upload-more");
  $btnDownloadTemplate = document.getElementById("btn-download-template");
  $uploadLoansTbody    = document.getElementById("upload-loans-tbody");
  $uploadLoansEmptyRow = document.getElementById("upload-loans-empty-row");
};

// ── Step Management ───────────────────────────────────────────────────────────
var _goToStep = function(n) {
  [1, 2, 3, 4].forEach(function(i) {
    var content   = document.getElementById("upload-step-" + i);
    var indicator = document.getElementById("step-ind-" + i);
    if (content) content.classList.toggle("d-none", i !== n);
    if (indicator) {
      var circle = indicator.querySelector("div:first-child");
      var label  = indicator.querySelector("div:last-child");
      if (i === n) {
        // Active step — orange
        circle.style.background = "#c45200"; circle.style.color = "#fff";
        circle.innerHTML = i;
        label.style.color = "#c45200"; label.style.fontWeight = "700";
      } else if (i < n) {
        // Completed step — green with checkmark
        circle.style.background = "#16a34a"; circle.style.color = "#fff";
        circle.innerHTML = "<i class='fa fa-check' style='font-size:11px;'></i>";
        label.style.color = "#16a34a"; label.style.fontWeight = "700";
      } else {
        // Future step — muted
        circle.style.background = "#fde0c0"; circle.style.color = "#c48060";
        circle.innerHTML = i;
        label.style.color = "#c48060"; label.style.fontWeight = "500";
      }
    }
  });

  // Update connector lines
  var lines = document.querySelectorAll(".flex-grow-1.mx-2");
  lines.forEach(function(line, idx) {
    line.style.background = (idx < n - 1) ? "#16a34a" : "#fde0c0";
    line.style.height = "2px";
    line.style.transition = "background .3s";
  });

  state.step = n;

  $btnPreview.classList.toggle("d-none",   n !== 1);
  $btnToAmort.classList.toggle("d-none",   n !== 2);
  $btnToConfirm.classList.toggle("d-none", n !== 3);
  $btnSave.classList.toggle("d-none",      n !== 4);
  $btnBack.classList.toggle("d-none",      n === 1);
};

// ── File Handling ─────────────────────────────────────────────────────────────
var _handleFileSelect = function(file) {
  if (!file) return;
  var ext     = file.name.toLowerCase().slice(file.name.lastIndexOf("."));
  var allowed = [".csv", ".xlsx", ".xls"];
  if (allowed.indexOf(ext) === -1) {
    alert("Invalid file type. Please upload CSV or Excel (.xlsx, .xls).");
    return;
  }
  state.file = file;
  $fileSelectedInfo.classList.remove("d-none");
  $fileNameDisplay.textContent = file.name;
  $fileSizeDisplay.textContent = formatBytes(file.size);
  $btnPreview.disabled = false;
};

var _clearFile = function() {
  state.file = null;
  $loanFileInput.value = "";
  $fileSelectedInfo.classList.add("d-none");
  $btnPreview.disabled = true;
};

// ── Step 1 - 2: Preview 
var _doPreview = function() {
  if (!state.file) return;
  $btnPreview.disabled = true;
  $btnPreview.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span>Processing...';

  var fd = new FormData();
  fd.append("file", state.file);
  fd.append("authenticity_token", csrfToken());

  fetch("/api/v1/upload_loans/preview", { method: "POST", body: fd })
    .then(function(r) { return r.json().then(function(d) { return { ok: r.ok, data: d }; }); })
    .then(function(r) {
      if (!r.ok) {
        var msgs = (r.data.errors && r.data.errors.full_messages) || ["Unknown error"];
        _showPreviewAlert(msgs);
        return;
      }
      state.previewLoans = r.data.loans || [];
      _renderPreviewTable();
      _goToStep(2);
    })
    .catch(function(e) { alert("Network error: " + e.message); })
    .finally(function() {
      $btnPreview.disabled = false;
      $btnPreview.innerHTML = '<i class="fa fa-eye me-1"></i>Preview Loans';
    });
};

var _showPreviewAlert = function(msgs) {
  $previewAlertList.innerHTML = msgs.map(function(m) { return "<li>" + m + "</li>"; }).join("");
  $previewAlert.classList.remove("d-none");
};

var _renderPreviewTable = function() {
  $previewTableTbody.innerHTML = "";
  state.previewLoans.forEach(function(loan, i) {
    var tr = document.createElement("tr");
    tr.innerHTML =
      "<td>" + (loan._row_number || i + 2) + "</td>" +
      "<td>" + (loan.member_id || "—") + "</td>" +
      "<td><small>" + (loan.loan_product_id || "—") + "</small></td>" +
      "<td class='text-end'>" + currency(loan.principal) + "</td>" +
      "<td class='text-center'>" + (loan.num_installments || "—") + "</td>" +
      "<td class='text-center'>" + (loan.term || "—") + "</td>" +
      "<td>" + (loan.date_prepared || "—") + "</td>" +
      "<td>" + (loan.date_released || "—") + "</td>" +
      "<td>" + (loan.first_date_of_payment || "—") + "</td>" +
      "<td>" + (loan.pn_number || "—") + "</td>" +
      "<td class='text-center'><span class='badge bg-success'><i class='fa fa-check'></i></span></td>";
    $previewTableTbody.appendChild(tr);
  });
};

// ── Step 2 - 3: Amortization
var _renderAmortSettingsTable = function() {
  $amortSettingsTbody.innerHTML = "";

  state.previewLoans.forEach(function(loan, i) {
    var term         = state.globalTerm || loan.term || "weekly";
    var firstPayment = loan.first_date_of_payment || state.globalFirstPayment || "";
    var maturity     = estimateMaturity(firstPayment, loan.num_installments, term);
    var hasCustom    = !!(state.amortOverrides[i] && Object.keys(state.amortOverrides[i]).length > 0);

    var tr = document.createElement("tr");
    tr.innerHTML =
      "<td>" + (i + 1) + "</td>" +
      "<td><small>" + (loan.member_id || "—") + "</small></td>" +
      "<td class='text-end'>" + currency(loan.principal) + "</td>" +
      "<td class='text-center'>" + term + "</td>" +
      "<td class='text-center'>" + (loan.num_installments || "—") + "</td>" +
      "<td><input type='date' class='form-control form-control-sm first-payment-row' " +
        "data-row='" + i + "' value='" + firstPayment + "' style='width:145px;'></td>" +
      "<td><small>" + maturity + "</small></td>" +
      "<td class='text-center'>" +
        "<button class='btn btn-sm btn-outline-secondary btn-customize-amort' type='button' data-row='" + i + "'>" +
          (hasCustom ? "<i class='fa fa-edit'></i> Edit" : "<i class='fa fa-calendar-alt'></i> Dates") +
        "</button>" +
        (hasCustom ? " <span class='badge bg-info text-white ms-1'>Custom</span>" : "") +
      "</td>";
    $amortSettingsTbody.appendChild(tr);
  });

  document.querySelectorAll(".first-payment-row").forEach(function(inp) {
    inp.addEventListener("change", function() {
      var row = parseInt(inp.dataset.row);
      state.previewLoans[row].first_date_of_payment = inp.value;
      _renderAmortSettingsTable();
    });
  });

  document.querySelectorAll(".btn-customize-amort").forEach(function(btn) {
    btn.addEventListener("click", function() {
      _openAmortDetailPanel(parseInt(btn.dataset.row));
    });
  });
};

var _openAmortDetailPanel = function(rowIndex) {
  state.editingRow = rowIndex;
  var loan         = state.previewLoans[rowIndex];
  var term         = state.globalTerm || loan.term || "weekly";
  var firstPayment = loan.first_date_of_payment || state.globalFirstPayment || "";
  var mir          = parseFloat(loan.monthly_interest_rate) || 0.013;
  var schedule     = computeSchedule(loan.principal, mir, loan.num_installments, term, firstPayment);
  var existing     = state.amortOverrides[rowIndex] || {};

  $amortPanelHeading.textContent =
    "Installment Dates — Row " + (rowIndex + 1) + " (Member: " + (loan.member_id || "—") + ")";

  $amortDetailTbody.innerHTML = "";

  schedule.forEach(function(row) {
    var customVal = existing[row.installment] || "";
    var tr = document.createElement("tr");
    tr.innerHTML =
      "<td class='text-center'>" + row.installment + "</td>" +
      "<td>" + (row.due_date || "—") + "</td>" +
      "<td><input type='date' class='form-control form-control-sm amort-custom-date' " +
        "data-installment='" + row.installment + "' value='" + customVal + "' style='width:145px;'></td>" +
      "<td class='text-end'>" + currency(row.principal) + "</td>" +
      "<td class='text-end'>" + currency(row.interest) + "</td>" +
      "<td class='text-end'>" + currency(row.amount_due) + "</td>";
    $amortDetailTbody.appendChild(tr);
  });

  $amortDetailPanel.classList.remove("d-none");
  $amortDetailPanel.scrollIntoView({ behavior: "smooth", block: "nearest" });
};

var _saveAmortDetailPanel = function() {
  var row       = state.editingRow;
  var overrides = {};
  document.querySelectorAll(".amort-custom-date").forEach(function(inp) {
    if (inp.value) overrides[parseInt(inp.dataset.installment)] = inp.value;
  });
  if (Object.keys(overrides).length > 0) {
    state.amortOverrides[row] = overrides;
  } else {
    delete state.amortOverrides[row];
  }
  $amortDetailPanel.classList.add("d-none");
  _renderAmortSettingsTable();
};

var _resetAmortDetailPanel = function() {
  document.querySelectorAll(".amort-custom-date").forEach(function(inp) { inp.value = ""; });
};

// ── Step 3 - 4: Confirm 
var _renderConfirmTable = function() {
  var customCount = Object.keys(state.amortOverrides).length;
  $confirmTotal.textContent       = state.previewLoans.length;
  $confirmValid.textContent       = state.previewLoans.length;
  $confirmCustomAmort.textContent = customCount;

  $confirmTableTbody.innerHTML = "";
  state.previewLoans.forEach(function(loan, i) {
    var fp        = loan.first_date_of_payment || state.globalFirstPayment || "—";
    var hasCustom = !!(state.amortOverrides[i] && Object.keys(state.amortOverrides[i]).length > 0);
    var paid      = parseInt(loan.paid_installments) || 0;
    var total     = parseInt(loan.num_installments) || 0;
    var remaining = total - paid;

    var paidBadge = paid > 0
      ? "<span class='badge bg-success'>" + paid + " paid</span> " +
        "<span class='badge bg-warning text-dark'>" + remaining + " left</span>"
      : "<span class='badge bg-secondary'>None</span>";

    var tr = document.createElement("tr");
    tr.innerHTML =
      "<td>" + (i + 1) + "</td>" +
      "<td><small>" + (loan.member_id || "—") + "</small></td>" +
      "<td class='text-end'>" + currency(loan.principal) + "</td>" +
      "<td class='text-center'>" + (loan.num_installments || "—") + "</td>" +
      "<td>" + fp + "</td>" +
      "<td class='text-center'>" +
        (hasCustom
          ? "<span class='badge bg-info text-white'><i class='fa fa-check'></i> Yes</span>"
          : "<span class='badge bg-secondary'>No</span>") +
      "</td>" +
      "<td class='text-center'>" + paidBadge + "</td>";
    $confirmTableTbody.appendChild(tr);
  });
};

// ── Save ──────────────────────────────────────────────────────────────────────
var _doSave = function() {
  $btnSave.disabled = true;
  $uploadSpinner.classList.remove("d-none");

  var loans = state.previewLoans.map(function(loan, i) {
    var merged = Object.assign({}, loan);
    if (state.globalTerm) merged.term = state.globalTerm;
    if (state.globalFirstPayment && !merged.first_date_of_payment)
      merged.first_date_of_payment = state.globalFirstPayment;

    var overrides = state.amortOverrides[i];
    if (overrides && Object.keys(overrides).length > 0) {
      merged.amortization_overrides = Object.keys(overrides).map(function(k) {
        return { installment_number: k, due_date: overrides[k] };
      });
    }
    return merged;
  });

  var fd = new FormData();
  fd.append("loans_payload", JSON.stringify({ loans: loans }));
  fd.append("authenticity_token", csrfToken());

  fetch("/api/v1/upload_loans/save", { method: "POST", body: fd })
    .then(function(r) { return r.json().then(function(d) { return { ok: r.ok, data: d }; }); })
    .then(function(r) {
      var uploadModal = bootstrap.Modal.getInstance($uploadModal);
      if (uploadModal) uploadModal.hide();

      if (r.ok) {
        _showResultSuccess(r.data);
      } else {
        _showResultError(r.data);
      }
    })
    .catch(function(e) { alert("Network error: " + e.message); })
    .finally(function() {
      $btnSave.disabled = false;
      $uploadSpinner.classList.add("d-none");
    });
};

// ── Result Modal ──────────────────────────────────────────────────────────────
var _showResultSuccess = function(data) {
  $resultSuccessMsg.textContent = data.saved_count + " loan(s) uploaded successfully. Amortization schedules generated.";
  $resultSuccess.classList.remove("d-none");
  $resultError.classList.add("d-none");
  $resultModalTitle.textContent = "Upload Successful";
  new bootstrap.Modal($resultModal).show();
  _refreshIndexTable(data.loans || []);
};

var _showResultError = function(data) {
  $resultErrorTbody.innerHTML = (data.errors || []).map(function(e) {
    return "<tr><td>" + e.row + "</td><td>" + (e.member_id || "—") + "</td>" +
           "<td>" + (e.messages || []).join(", ") + "</td></tr>";
  }).join("");
  $resultError.classList.remove("d-none");
  $resultSuccess.classList.add("d-none");
  $resultModalTitle.textContent = "Upload Failed";
  new bootstrap.Modal($resultModal).show();
};

// ── Index Table Refresh ───────────────────────────────────────────────────────
var _refreshIndexTable = function(savedLoans) {
  if ($uploadLoansEmptyRow) $uploadLoansEmptyRow.remove();

  savedLoans.forEach(function(result) {
    var loan = state.previewLoans[result.row - 1] || {};
    var fp   = loan.first_date_of_payment || state.globalFirstPayment || "—";

    var tr = document.createElement("tr");
    tr.innerHTML =
      "<td>" + result.row + "</td>" +
      "<td><small>" + (result.member_id || "—") + "</small></td>" +
      "<td><small>" + (loan.branch_id || "—") + "</small></td>" +
      "<td><small>" + (loan.center_id || "—") + "</small></td>" +
      "<td><small>" + (loan.loan_product_id || "—") + "</small></td>" +
      "<td class='text-end'>" + currency(loan.principal) + "</td>" +
      "<td class='text-center'>" + (loan.num_installments || "—") + "</td>" +
      "<td class='text-center'>" + (loan.term || "—") + "</td>" +
      "<td>" + (loan.date_prepared || "—") + "</td>" +
      "<td>" + (loan.date_released || "—") + "</td>" +
      "<td>" + fp + "</td>" +
      "<td>" + (loan.pn_number || "—") + "</td>" +
      "<td class='text-center'>" +
        "<button class='btn btn-sm btn-outline-info btn-view-amort' type='button' " +
          "data-loan-id='" + result.loan_id + "' " +
          "data-bs-toggle='modal' data-bs-target='#amortization-modal'>" +
          "<i class='fa fa-calendar-alt'></i>" +
        "</button>" +
      "</td>" +
      "<td class='text-center'><span class='badge bg-success'>Uploaded</span></td>";
    $uploadLoansTbody.appendChild(tr);
  });

  _bindAmortViewButtons();
};

// ── Amortization View Modal
var _bindAmortViewButtons = function() {
  document.querySelectorAll(".btn-view-amort").forEach(function(btn) {
    btn.addEventListener("click", function() {
      _loadAmortization(btn.dataset.loanId);
    });
  });
};

var _loadAmortization = function(loanId) {
  var tbody = document.getElementById("amort-view-tbody");
  tbody.innerHTML = "<tr><td colspan='6' class='text-center'><i class='fa fa-spinner fa-spin me-1'></i>Loading...</td></tr>";

  fetch("/api/v1/upload_loans/amortization?loan_id=" + loanId)
    .then(function(r) { return r.json(); })
    .then(function(data) {
      var loan = data.loan || {};
      document.getElementById("amort-view-loan-info").textContent    = "Loan ID: " + loanId;
      document.getElementById("amort-view-principal").textContent    = currency(loan.principal);
      document.getElementById("amort-view-interest").textContent     = currency(loan.interest);
      document.getElementById("amort-view-term").textContent         = loan.term || "—";
      document.getElementById("amort-view-installments").textContent = loan.num_installments || "—";
      document.getElementById("amort-view-first-date").textContent   = loan.first_date_of_payment || "—";
      document.getElementById("amort-view-maturity").textContent     = loan.maturity_date || "—";

      tbody.innerHTML = "";
      (data.entries || []).forEach(function(e, i) {
        var isPaid      = e.principal_balance === 0 && e.interest_balance === 0;
        var isPartial   = !isPaid && (e.principal_paid > 0 || e.interest_paid > 0);
        var statusBadge = isPaid
          ? "<span class='badge bg-success'>Paid</span>"
          : isPartial
            ? "<span class='badge bg-warning text-dark'>Partial</span>"
            : "<span class='badge bg-secondary'>Unpaid</span>";

        var tr = document.createElement("tr");
        tr.innerHTML =
          "<td class='text-center'>" + (i + 1) + "</td>" +
          "<td>" + (e.due_date || "—") + "</td>" +
          "<td class='text-end'>" + currency(e.principal) + "</td>" +
          "<td class='text-end'>" + currency(e.interest) + "</td>" +
          "<td class='text-end'><strong>" + currency(e.amount_due) + "</strong></td>" +
          "<td class='text-center'>" + statusBadge + "</td>";
        tbody.appendChild(tr);
      });
    })
    .catch(function() {
      tbody.innerHTML = "<tr><td colspan='6' class='text-center text-danger'>Failed to load amortization.</td></tr>";
    });
};

// ── CSV Template Download
var _downloadTemplate = function() {
  var headers = [
    "member_id", "branch_id", "center_id", "loan_product_id",
    "principal", "num_installments", "term",
    "date_prepared", "date_released", "first_date_of_payment",
    "pn_number", "payment_type",
    "bank_check_number", "check_number", "date_requested", "date_of_check", "paid_installments",
    "first_co_maker_id", "second_co_maker_id", "third_co_maker_id"
  ];
  var sample = [
    "MEMBER-UUID", "BRANCH-UUID", "CENTER-UUID", "PRODUCT-UUID",
    "5000", "25", "weekly",
    "2025-09-12", "2025-09-12", "2025-09-19",
    "PN-001", "cash",
    "BCN-001", "CVN-001", "2025-09-12", "2025-09-12", "15",
    "MEMBER-UUID", "MEMBER-UUID", "MEMBER-UUID"
  ];
  var csv  = [headers.join(","), sample.join(",")].join("\n");
  var blob = new Blob([csv], { type: "text/csv" });
  var url  = URL.createObjectURL(blob);
  var a    = document.createElement("a");
  a.href     = url;
  a.download = "loan_upload_template.csv";
  a.click();
  URL.revokeObjectURL(url);
};

// ── Reset State
var _resetState = function() {
  state.step               = 1;
  state.file               = null;
  state.previewLoans       = [];
  state.amortOverrides     = {};
  state.globalFirstPayment = null;
  state.globalTerm         = null;
  state.editingRow         = null;
  $loanFileInput.value = "";
  $fileSelectedInfo.classList.add("d-none");
  $btnPreview.disabled = true;
  $previewAlert.classList.add("d-none");
  $amortDetailPanel.classList.add("d-none");
  $globalFirstPayment.value = "";
  $globalTermOverride.value = "";
};

// ── Bind Events
var _bindEvents = function() {
  if ($btnOpenUploadModal) {
    $btnOpenUploadModal.addEventListener("click", function() {
      _resetState();
      _goToStep(1);
      new bootstrap.Modal($uploadModal).show();
    });
  }

  $loanFileInput.addEventListener("change", function(e) {
    _handleFileSelect(e.target.files[0]);
  });

  $dropZone.addEventListener("dragover", function(e) {
    e.preventDefault();
    $dropZone.classList.add("border-primary", "bg-primary", "bg-opacity-10");
  });
  $dropZone.addEventListener("dragleave", function() {
    $dropZone.classList.remove("border-primary", "bg-primary", "bg-opacity-10");
  });
  $dropZone.addEventListener("drop", function(e) {
    e.preventDefault();
    $dropZone.classList.remove("border-primary", "bg-primary", "bg-opacity-10");
    _handleFileSelect(e.dataTransfer.files[0]);
  });

  $btnClearFile.addEventListener("click", _clearFile);
  $btnPreview.addEventListener("click", _doPreview);

  $btnToAmort.addEventListener("click", function() {
    _renderAmortSettingsTable();
    _goToStep(3);
  });

  $btnSaveAmortDetail.addEventListener("click",  _saveAmortDetailPanel);
  $btnResetAmortDetail.addEventListener("click", _resetAmortDetailPanel);
  $btnCloseAmortPanel.addEventListener("click",  function() {
    $amortDetailPanel.classList.add("d-none");
  });

  $globalFirstPayment.addEventListener("change", function(e) {
    state.globalFirstPayment = e.target.value;
    _renderAmortSettingsTable();
  });
  $globalTermOverride.addEventListener("change", function(e) {
    state.globalTerm = e.target.value || null;
    _renderAmortSettingsTable();
  });

  $btnToConfirm.addEventListener("click", function() {
    _renderConfirmTable();
    _goToStep(4);
  });

  $btnSave.addEventListener("click", _doSave);

  $btnBack.addEventListener("click", function() {
    if (state.step > 1) _goToStep(state.step - 1);
  });

  if ($btnUploadMore) {
    $btnUploadMore.addEventListener("click", function() {
      bootstrap.Modal.getInstance($resultModal).hide();
    });
  }

  $btnDownloadTemplate.addEventListener("click", _downloadTemplate);
};

// ── Init
var init = function(config) {
  _cacheDom();
  _bindEvents();
};

export default { init: init };