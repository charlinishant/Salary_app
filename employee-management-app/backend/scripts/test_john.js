async function test() {
  const res = await fetch('http://localhost:5000/api/employees?search=John');
  const data = await res.json();
  console.log(JSON.stringify(data, null, 2));
}
test();
