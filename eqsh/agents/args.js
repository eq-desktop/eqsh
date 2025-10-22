function parse(str) {
  const obj = {};
  // Split by comma, then process each key=value pair
  str.split(",").forEach(part => {
    const [key, value] = part.split("=").map(s => s.trim());
    if (key) obj[key] = value ?? true;
  });
  return obj;
}