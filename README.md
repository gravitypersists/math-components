mathprototypes
==============

Live writeup: https://gravitypersists.github.io/math-components/ (matrix transformation demo: [demos/transform.html](https://gravitypersists.github.io/math-components/demos/transform.html))

Open index.html for demos. Main source code is in Coffeescript in scripts/ and uses a charting plugin library on top of Raphael.js

The compiled `scripts/*.js` files are committed so the site can be served statically. After editing a `.coffee` file, rebuild with:

    npx -p coffee-script@1.12.7 coffee -c scripts/
