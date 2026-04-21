function pad2(n: number): string {
  return n < 10 ? `0${n}` : `${n}`;
}

export function formatDateTimeMs(ms: number): string {
  const d: Date = new Date(ms);
  return `${d.getFullYear()}-${pad2(d.getMonth() + 1)}-${pad2(d.getDate())} ${pad2(d.getHours())}:${pad2(d.getMinutes())}`;
}
