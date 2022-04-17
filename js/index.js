const imports = {
  imports: {},
};

fetch("binary.wasm")
  .then((response) => response.arrayBuffer())
  .then((bytes) => WebAssembly.instantiate(bytes, imports))
  .then((results) => {
    instance = results.instance;
    // grab our exported function from wasm
    const add = results.instance.exports.add;
    console.log(add(3, 4));
  });

const navbarInput = document.getElementById("navbarInput");
const navbarUploadButton = document.getElementById("navbarUploadButton");

const readFile = (file) =>
  new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => resolve(reader.result);
    reader.onerror = (error) => reject(error);

    reader.readAsText(file);
  });

navbarUploadButton.addEventListener("click", (evt) => {
  evt.preventDefault();

  navbarInput.click();
});

navbarInput.addEventListener("change", (evt) => {
  evt.preventDefault();

  // evt.target.files is a FileList
  const files = Array.from(evt.target.files);

  files.forEach((file) => {
    console.log("changed", file);
  });
});
