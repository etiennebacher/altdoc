# Deployment

`docsify.js`, `docute` and `mkdocs` documentations can be deployed with
several tools. The authors of these documentation generators have all
written detailed guides to deployment, which you can read here:

-   [Docsify deployment](https://docsify.js.org/#/deploy)
-   [Docute deployment](https://docute.egoist.dev/guide/deployment)
-   [MkDocs
    deployment](https://www.mkdocs.org/user-guide/deploying-your-docs/).

I’ll just focus on GitHub Pages and Netlify here.

## GitHub Pages

Deploying package documentation to Github Pages is very convenient. With
this strategy you can point readers to an address like
`mypackage.github.io` or to a custom domain of your choice.

The process is usually very simple:

1.  Go to your Github repository settings.
2.  Click on “Pages” in the left sidebar.
3.  Under “Build and deployment”, select:
    -   Deploy from branch
    -   Branch: `main` or `master` (depending on your git repository
        settings)
    -   Select folder: `docs/`
4.  Update your `altdoc` site, commit, and push to Github.

Detailed instructions are available on Github’s website:

-   https://docs.github.com/en/pages
-   https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site
    \[Github offers\]

## Netlify

The process is the same as for deploying a blog made with `{blogdown}`,
so we invite you to follow the steps described in the [`{blogdown}`
book](https://bookdown.org/yihui/blogdown/netlify.html).

In case this is useful, we now describe how Etienne got his
documentation deployed with an address like `mypackage.mywebsite.com`.
The context is:

-   Website made with `{distill}`, deployed through Netlify;
-   Custom domain name, such as `mywebsite.com`;
-   We would like to have the package documentation as a subdomain, such
    as `mypackage.mywebsite.com`.

If you are in the same situation, you can follow the steps below.
Otherwise, you should refer to `docsify.js` documentation linked above.

1.  Push your package with the documentation to GitHub.
2.  Log into Netlify with your GitHub account.
3.  Create a “New site from Git” and choose GitHub as Git provider.
4.  Choose the repo containing your package.
5.  In “Basic build settings”, write “docs” (the name of the folder
    where the documentation is stored) in “Publish directory”. Click on
    “Deploy site”.

Your page with the documentation is created, but the domain is a random
name so we need to change it.

1.  Click on “Domain settings”. In “Custom domains”, click on “Add
    custom domain”.
2.  Add a custom domaine name. For example, if you own `mywebsite.com`,
    you can name the custom domain as `mypackage.mywebsite.com`.
3.  Confirm that you are the owner of `mywebsite.com`.
4.  Force HTTPS (automatically proposed by Netlify).

Done! You can now check at `mypackage.mywebsite.com` that the
documentation is well loaded. This will update every time you push
changes in `/docs` on GitHub.