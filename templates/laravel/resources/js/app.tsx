import "../css/app.css"
import './bootstrap';
import { createInertiaApp } from '@inertiajs/react'
import { createRoot } from 'react-dom/client'
import { resolvePageComponent } from "laravel-vite-plugin/inertia-helpers"

const appName = import.meta.env.VITE_APP_NAME || "Laravel"

createInertiaApp({
  title: (title) => (title ? `${title} / ${appName}` : appName),
  resolve: (name) =>
    resolvePageComponent(`./pages/${name}.tsx`, import.meta.glob("./pages/**/*.tsx")),
  setup({ el, App, props }) {
    createRoot(el).render(<App {...props} />)
  },
})
