const terminalText = document.getElementById("terminalText");

let instance = null;
let exports = null;

const encoder = new TextEncoder();
const decoder = new TextDecoder();

const sendString = (str) => {
  const encodedString = encoder.encode(str);

  const u8 = new Uint8Array(exports.mem);

  // Copy the UTF-8 encoded string into the WASM memory.
  u8.set(encodedString);
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

      const string = decoder.decode(buffer);

      const length = objectBuffer.length;
      objectBuffer.push(string);

      return length;
    },

    logObj: (objIndex) => {
      const value = objectBuffer[objIndex];
      if (typeof value === "string") {
        terminalText.innerText += value;
      } else {
        terminalText.innerText += JSON.stringify(value) + "\n";
      }
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
    exports = instance.exports;

    // grab our exported function from wasm
    const add = exports.add;
    console.log(add(3, 4));
  });

const readFile = (file) =>
  new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => resolve(reader.result);
    reader.onerror = (error) => reject(error);

    reader.readAsText(file);
  });

const navbarInput = document.getElementById("navbarInput");
const navbarUploadButton = document.getElementById("navbarUploadButton");

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

const editorPane = document.getElementById("editorPane");
const terminalPane = document.getElementById("terminalPane");
const resizer = document.getElementById("resizer");

let leftWidth = editorPane.getBoundingClientRect().width;
let resizing = false;
let xPos = undefined;

resizer.addEventListener("mousedown", (evt) => {
  evt.preventDefault();

  resizing = true;
  xPos = evt.clientX;
});

window.addEventListener("mouseup", (evt) => {
  if (resizing) {
    evt.preventDefault();

    resizing = false;
  }
});

window.addEventListener("mousemove", (evt) => {
  if (resizing) {
    evt.preventDefault();

    const newX = evt.clientX;
    leftWidth += newX - xPos;
    editorPane.style.width = `${leftWidth}px`;
    xPos = newX;
  }
});

editorPane.style.width = `${leftWidth}px`;
