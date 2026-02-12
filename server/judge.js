function stringifyValue(v) {
  return JSON.stringify(v);
}

function normalizeSet(rows) {
  return (rows ?? []).map(r => JSON.stringify(r)).sort();
}

function normalizeOrdered(rows) {
  return (rows ?? []).map(r => JSON.stringify(r));
}

function normalizeAggregate(rows) {
  return (rows ?? [])
    .map(r => {
      const valuesSorted = Object.values(r).map(stringifyValue).sort();
      return JSON.stringify(valuesSorted);
    })
    .sort();
}

function isSameByMode(userRows, answerRows, mode) {
  if (mode === "ordered") {
    const a = normalizeOrdered(userRows);
    const b = normalizeOrdered(answerRows);
    if (a.length !== b.length) return false;
    for (let i = 0; i < a.length; i++) if (a[i] !== b[i]) return false;
    return true;
  }

  if (mode === "aggregate") {
    const a = normalizeAggregate(userRows);
    const b = normalizeAggregate(answerRows);
    if (a.length !== b.length) return false;
    for (let i = 0; i < a.length; i++) if (a[i] !== b[i]) return false;
    return true;
  }

  // default = set
  const a = normalizeSet(userRows);
  const b = normalizeSet(answerRows);
  if (a.length !== b.length) return false;
  for (let i = 0; i < a.length; i++) if (a[i] !== b[i]) return false;
  return true;
}

module.exports = { isSameByMode };
