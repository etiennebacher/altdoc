# Deploy

## How to deploy

`docsify.js`, `docute` and `mkdocs` documentations can be deployed with several tools, which are detailed respectively [here](https://docsify.js.org/#/deploy), [here](https://docute.egoist.dev/guide/deployment) and [here](https://www.mkdocs.org/user-guide/deploying-your-docs/). I'll just focus on GitHub Pages and Netlify here.


### GitHub Pages

It is very easy to deploy the documentation with GitHub Pages so I start with this. If you have ever used `{pkgdown}`, this is the same process: go to your GitHub repo settings, add "docs" as the source of GitHub Pages, and that's it!


### Netlify

The process is the same as for deploying a blog made with `{blogdown}`, so I invite you to follow the steps described in the [`{blogdown}` book](https://bookdown.org/yihui/blogdown/netlify.html).


## Personal experience

In case it helps some people, I describe here how I got this documentation deployed with an address like `mypackage.mywebsite.com`. This is the situation I am in:

* I have a website made with `{distill}`, deployed through Netlify;

* I have a custom domain name, such as `mywebsite.com`;

* I would like to have the package documentation as a subdomain, such as `mypackage.mywebsite.com`.

If you are in the same situation, you can follow the steps below. Otherwise, you should refer to `docsify.js` documentation linked above.

**Step 1:** Push your package with the documentation to GitHub.

**Step 2:** Log into Netlify with your GitHub account.

**Step 3:** Create a "New site from Git" and choose GitHub as Git provider.

**Step 4:** Choose the repo containing your package.

**Step 5:** In "Basic build settings", write "docs" (the name of the folder where the documentation is stored) in "Publish directory". Click on "Deploy site".

Your page with the documentation is created, but the domain is a random name so we need to change it.

**Step 6:** Click on "Domain settings". In "Custom domains", click on "Add custom domain". 

**Step 7:** Add a custom domaine name. For example, if you own `mywebsite.com`, you can name the custom domain as `mypackage.mywebsite.com`.

**Step 8:** Confirm that you are the owner of `mywebsite.com`.

**Step 9:** Force HTTPS (automatically proposed by Netlify).

Done! You can now check at `mypackage.mywebsite.com` that the documentation is well loaded. This will update every time you push changes in `/docs` on GitHub.



