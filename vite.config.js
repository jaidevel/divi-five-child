import { defineConfig } from 'vite';
import path from 'path';

export default defineConfig({
    build: {
        rollupOptions: {
            input: path.resolve(__dirname, 'src/js/main.js'),
            output: {
                dir: path.resolve(__dirname, '.'), // Output to current directory
                entryFileNames: 'main.js', // Name the file exactly
                format: 'iife',
                name: 'ThemeMain',
            },
        },
        outDir: '.', // Required for vite to not move to dist/
        emptyOutDir: false, // Don't delete other files
        sourcemap: true,
    },
    server: {
        watch: {
            ignored: ['!**/src/js/**'],
        },
    },
});
