import { defineConfig } from 'jsrepo';

export default defineConfig({
    registries: ["https://vue-bits.dev/r"],
    paths: {
        "*": './app/components/bits',
        "RotatingText": './app/components/bits',
		component: './app/components/bits'
    },
});
