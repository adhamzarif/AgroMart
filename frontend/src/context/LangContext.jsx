import { createContext, useContext, useState } from 'react';
import { strings } from '../i18n/strings.js';

const LangContext = createContext(null);

export function LangProvider({ children }) {
  const [lang, setLang] = useState('bn'); // Bengali default
  const t = (key) => strings[lang][key] ?? strings.bn[key] ?? key;
  const toggle = () => setLang((l) => (l === 'bn' ? 'en' : 'bn'));
  return (
    <LangContext.Provider value={{ lang, setLang, toggle, t }}>
      {children}
    </LangContext.Provider>
  );
}

export function useLang() {
  const ctx = useContext(LangContext);
  if (!ctx) throw new Error('useLang must be used inside <LangProvider>');
  return ctx;
}
