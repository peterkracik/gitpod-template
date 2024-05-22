const themePath = "html/wp-content/themes/turistika";
const dirs = {
    src: `${themePath}/src/`,
    dist: `${themePath}/assets/`,
}

export const paths = {
    theme: `${themePath}/`,
    src: {
        dir: `${dirs.src}`,
        scripts: `${dirs.src}scripts/`,
        styles: `${dirs.src}styles/`,
        images: `${dirs.src}images/`,
        fonts: `${dirs.src}fonts/`,
        views: `${dirs.src}views/`,
        iconfont: `${dirs.src}images/icons/`,
    },
    dist: {
        dir: `${dirs.dist}`,
        scripts: `${dirs.dist}scripts/`,
        styles: `${dirs.dist}styles/`,
        images: `${dirs.dist}images/`,
        fonts: `${dirs.dist}fonts/`,
        iconfont: `${dirs.dist}fonts/`,
    }
};