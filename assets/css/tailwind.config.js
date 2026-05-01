/** @type {import('tailwindcss').Config} */
module.exports = {
  theme: {
    extend: {
      typography: (theme) => ({
        DEFAULT: {
          css: {
            "--tw-prose-pre-bg": "oklch(0.2025 0.0032 17.42)",
            "--tw-prose-invert-pre-bg": "oklch(0.2025 0.0032 17.42)",

            "--tw-prose-pre-code": "oklch(0.8316 0.007 145.51)",
            "--tw-prose-invert-pre-code": "oklch(0.8316 0.007 145.51)",

            // Code blocks
            pre: {
              '@media (min-width: theme("screens.lg"))': {
                marginInline: "calc(var(--spacing) * -8)",
              },
              borderRadius: "var(--radius-lg)",
            },
          },
        },
      }),
    },
  },
};
