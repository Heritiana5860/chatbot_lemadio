/** @type {import('tailwindcss').Config} */
export const content = ["./src/**/*.{js,jsx,ts,tsx}"];
export const theme = {
  extend: {
    colors: {
      primary: {
        DEFAULT: "#4B8A34",
        50: "#E8F5E3",
        100: "#D1EBC7",
        200: "#A3D78F",
        300: "#75C357",
        400: "#5DA740",
        500: "#4B8A34",
        600: "#3D6E2A",
        700: "#2F5320",
        800: "#213715",
        900: "#131C0B",
      },
      accent: {
        DEFAULT: "#FFCC00",
        50: "#FFF9E5",
        100: "#FFF3CC",
        200: "#FFE799",
        300: "#FFDB66",
        400: "#FFCF33",
        500: "#FFCC00",
        600: "#CCA300",
        700: "#997A00",
        800: "#665200",
        900: "#332900",
      },
    },
    fontFamily: {
      sans: ["Inter", "system-ui", "sans-serif"],
    },
  },
};
export const plugins = [];
