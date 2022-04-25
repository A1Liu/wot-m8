const PANEL = "windows-panel";
const RESIZER = "windows-resizer";
const TABBED = "windows-tabbed";
const TABBED_CONTENT = "windows-tabbed-content";
const TAB_BAR = "windows-tabbar";
const TAB = "windows-tab";

const VERTICAL = "vertical"; // top-to-bottom
const HORIZONTAL = "horizontal"; // left-to-right

export const AFTER = "windows-AFTER";
export const BEFORE = "windows-BEFORE";

// TODO use percentages in the styles instead of other things
// mouse resize requires more complicated computations

// Mutable Globals
let g_resizeState = null;

// Utilities
const freezeDimension = (child, isVert) => {
  const bbox = child.getBoundingClientRect();

  if (isVert) {
    child.style.height = `${bbox.height}px`;
    return bbox.height;
  } else {
    child.style.width = `${bbox.width}px`;
    return bbox.width;
  }
};

window.addEventListener("mouseup", (evt) => {
  if (g_resizeState) {
    evt.preventDefault();

    g_resizeState = null;
  }
});

window.addEventListener("mousemove", (evt) => {
  if (g_resizeState) {
    evt.preventDefault();

    const { isVert, newChild, resizerBefore, regionSize } = g_resizeState;

    const newPos = isVert ? evt.clientY : evt.clientX;
    g_resizeState.beforeSize += newPos - g_resizeState.pos;
    g_resizeState.pos = newPos;

    const beforeSize = g_resizeState.beforeSize;
    const childSize = regionSize - g_resizeState.beforeSize;

    if (isVert) {
      resizerBefore.style.height = `${beforeSize}px`;
      newChild.style.height = `${childSize - 1}px`;
    } else {
      resizerBefore.style.width = `${beforeSize}px`;
      newChild.style.width = `${childSize - 1}px`;
    }
  }
});

const resizeMousedownListener = (evt) => {
  evt.preventDefault();
  evt.stopPropagation();

  const resizer = evt.target;
  const resizerBefore = resizer.previousSibling;
  const newChild = resizer.nextSibling;
  const parent = resizer.parentNode;

  const isVert = parent.classList.contains(VERTICAL);
  const pos = isVert ? evt.clientY : evt.clientX;

  g_resizeState = { isVert, resizerBefore, newChild, pos };

  Array.from(parent.children).forEach((child, index) => {
    if (index % 2 === 1) {
      return;
    }

    const result = freezeDimension(child, isVert);
    if (child === resizerBefore) {
      g_resizeState.beforeSize = result;
    }

    if (child === newChild) {
      g_resizeState.regionSize = result + g_resizeState.beforeSize;
    }
  });
};

export const TabbedWindow = (title, content) => {
  const tabbedWindow = document.createElement("div");
  const tabBar = document.createElement("div");
  const tab = document.createElement("div");

  tabbedWindow.classList.add(TABBED);
  tabBar.classList.add(TAB_BAR);
  tab.classList.add(TAB);
  content.classList.add(TABBED_CONTENT);

  tab.textContent = title;

  tabBar.appendChild(tab);
  tabbedWindow.appendChild(tabBar);
  tabbedWindow.appendChild(content);

  return tabbedWindow;
};

export const appendChild = (parent, newChild) => {
  const classList = parent.classList;
  const isVert = classList.contains(VERTICAL);
  const isHorizontal = classList.contains(HORIZONTAL);

  const isValid = classList.contains(PANEL) && (isVert || isHorizontal);
  if (!isValid) {
    console.warn("tried to append to invalid value");
    return;
  }

  const parentBox = parent.getBoundingClientRect();
  newChild.style.width = `100%`;
  newChild.style.height = `100%`;

  if (parent.children.length <= 0) {
    parent.appendChild(newChild);
    return;
  }

  const elementCount = Math.ceil(parent.children.length / 2);
  const resizerCount = elementCount - 1;

  const parentSize = isVert ? parentBox.height : parentBox.width;

  // each resizer is 1px
  const avgElementSize = (parentSize - resizerCount) / elementCount;

  Array.from(parent.children).forEach((child, index) => {
    if (index % 2 === 1) {
      return;
    }

    freezeDimension(child, isVert);
  });

  const resizer = document.createElement("span");
  resizer.classList.add(RESIZER);
  resizer.role = "presentation";
  resizer.addEventListener("mousedown", resizeMousedownListener);

  if (isVert) {
    newChild.style.height = `${avgElementSize}px`;
  } else {
    newChild.style.width = `${avgElementSize}px`;
  }

  parent.appendChild(resizer);
  parent.appendChild(newChild);

  return;
};
