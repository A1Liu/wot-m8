let instance = null;

const sendString = () => {
  const encoder = new TextEncoder();
  const encodedString = encoder.encode(str);

  const i8 = new Uint8Array(exports.mem);

  // Copy the UTF-8 encoded string into the WASM memory.
  i8.set(encodedString);
};

const objectBuffer = [];

const imports = {
  env: {
    stringObjExt: (location, size) => {
      const buffer = new Uint8Array(
        instance.exports.memory.buffer,
        location,
        size
      );

      const decoder = new TextDecoder();
      const string = decoder.decode(buffer);

      const length = objectBuffer.length;
      objectBuffer.push(string);

      return length;
    },
    logObj: (value) => {
      console.log(objectBuffer[value]);
    },
    clearObjBuffer: () => {
      objectBuffer.length = 0;
    },
  },
};

fetch("binary.wasm")
  .then((resp) => WebAssembly.instantiateStreaming(resp, imports))
  .then((result) => {
    instance = result.instance;

    // grab our exported function from wasm
    const add = instance.exports.add;
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
