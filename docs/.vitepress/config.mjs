import { defineConfig } from 'vitepress'
// https://vitepress.dev/reference/site-config
export default defineConfig({
    title: "Snow Blower",
    description: "opinionated config manager.",
    base: '/snow-blower/',

    ignoreDeadLinks: [
        /^https?:\/\/localhost/
    ],

    themeConfig: {
        // https://vitepress.dev/reference/default-theme-config
        outline: {
            level: [2, 3],
            label: 'On this page'
        },
        nav: [
            { text: 'Home', link: '/' },
        ],

        sidebar: [
            {
                text: 'Getting Started',
                items: [
                    { text: 'Introduction', link: '/' },
                    { text: 'Getting Started', link: '/getting-started' },
                ]
            },
            {
                text: 'Tools',
                items: [
                    {
                        text: 'JavaScript',
                        collapsed: false,
                        items: [
                            { text: 'Prettier', link: '/tools/javascript/prettier' },
                            { text: 'Yarn', link: '/tools/javascript/yarn' }
                        ]
                    },
                    {
                        text: 'Python',
                        collapsed: false,
                        items: [
                            { text: 'Overview', link: '/tools/python/index' },
                            { text: 'Ruff', link: '/tools/python/ruff' },
                            { text: 'UV', link: '/tools/python/uv' }
                        ]
                    }
                ]
            }
        ],

        socialLinks: [
            { icon: 'github', link: 'https://github.com/use-the-fork/snow-blower' }
        ],

        footer: {
            message: 'Released under the MIT License.',
            copyright: 'Copyright © 2023-present Snow Blower Contributors'
        },

        search: {
            provider: 'local'
        }
    }
})
