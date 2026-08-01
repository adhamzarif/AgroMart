/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,jsx}'],
  theme: {
    extend: {
      colors: {
        // Module palette (from tokens.css)
        m1: { DEFAULT: '#2E7D32', light: '#66BB6A', dark: '#1B5E20' }, // User & Marketplace
        m2: { DEFAULT: '#1976D2', light: '#42A5F5', dark: '#0D47A1' }, // Analytics
        m3: { DEFAULT: '#F57C00', light: '#FFB74D', dark: '#E65100' }, // Financial
        m4: { DEFAULT: '#7B1FA2', light: '#BA68C8', dark: '#4A148C' }, // AI
        m5: { DEFAULT: '#00796B', light: '#4DB6AC', dark: '#004D40' }, // Advanced
        success: { DEFAULT: '#4CAF50', light: '#81C784', dark: '#388E3C', bg: '#E8F5E9' },
        warning: { DEFAULT: '#FF9800', light: '#FFB74D', dark: '#F57C00', bg: '#FFF3E0' },
        danger:  { DEFAULT: '#F44336', light: '#E57373', dark: '#D32F2F', bg: '#FFEBEE' },
        info:    { DEFAULT: '#2196F3', light: '#64B5F6', dark: '#1976D2', bg: '#E3F2FD' },
      },
      fontFamily: {
        bn: ['"Noto Sans Bengali"', 'sans-serif'],
        en: ['Inter', 'sans-serif'],
        display: ['Poppins', 'sans-serif'],
        mono: ['"JetBrains Mono"', 'monospace'],
      },
      boxShadow: {
        1: '0 1px 2px rgba(0,0,0,0.05)',
        2: '0 2px 4px rgba(0,0,0,0.06)',
        3: '0 4px 8px rgba(0,0,0,0.08)',
        4: '0 8px 16px rgba(0,0,0,0.12)',
        5: '0 12px 24px rgba(0,0,0,0.15)',
      },
      borderRadius: { xl2: '16px' },
    },
  },
  plugins: [],
};
