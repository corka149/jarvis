document.addEventListener("DOMContentLoaded", function () {
  const themeToggle = document.getElementById("theme-toggle");
  
  themeToggle.checked = localStorage.getItem("dark") === "on";

  themeToggle.addEventListener("click", function () {
    const darkOn = localStorage.getItem("dark") === "on";
    localStorage.setItem("dark", darkOn ? "off" : "on")
  });
});