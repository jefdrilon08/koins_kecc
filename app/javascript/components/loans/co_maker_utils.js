export const getCoMakerLabel = (index) => {
  const labels = ['First Co-maker', 'Second Co-maker', 'Third Co-maker'];
  return labels[index] || `${index + 1}th Co-maker`;
};

export const normalizeAmount = (value) => {
  if (value === null || value === undefined || value === '') return 0;

  const cleaned = String(value).trim().replace(/,/g, '');
  const numericValue = Number(cleaned);
  return Number.isFinite(numericValue) ? numericValue : 0;
};

export const getCoMakerTotal = (entries = []) => entries.reduce((sum, entry) => {
  const value = normalizeAmount(entry?.amount ?? 0);
  return sum + (Number.isFinite(value) ? value : 0);
}, 0);

export const getCoMakerRemainingAmount = (entries = [], loanAmount) => {
  const total = getCoMakerTotal(entries);
  const target = normalizeAmount(loanAmount);
  return Math.max(0, target - total);
};

export const canAddMoreCoMakers = (entries = [], loanAmount) => {
  const total = getCoMakerTotal(entries);
  const target = normalizeAmount(loanAmount);
  return total < target;
};

export const getPotentialAdditionalCoMakers = (entries = [], loanAmount, maxAllowed, amountInputValue) => {
  const remaining = getCoMakerRemainingAmount(entries, loanAmount);
  const unit = normalizeAmount(amountInputValue ?? 1) || 1;
  const base = unit > 0 ? unit : 1;
  const slots = Number.isFinite(maxAllowed) ? Math.max(0, maxAllowed - entries.length) : 0;

  if (slots <= 0 || remaining <= 0) return 0;
  return Math.min(slots, Math.floor(remaining / base));
};