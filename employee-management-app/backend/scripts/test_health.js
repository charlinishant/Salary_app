async function test() {
  try {
    const health = await fetch('http://localhost:5000/health').then(r => r.json());
    console.log('Backend Health Status:', health);
  } catch (e) {
    console.error('Backend Health Error:', e.message);
  }
}
test();
