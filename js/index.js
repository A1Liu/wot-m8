// define our imports
var imports = {
    imports: {
    }
};

fetch("binary.wasm")
  .then((response) => { return response.arrayBuffer(); })
  .then((bytes) => { return WebAssembly.instantiate(bytes, imports); })
  .then((results)=> {
    instance = results.instance;
    // grab our exported function from wasm
    const add = results.instance.exports.add;
    console.log(add(3, 4));
});
