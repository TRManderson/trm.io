docker pull jekyll/builder
docker run --rm --name jekyll -v `pwd`:/srv/jekyll -it -p 4000:4000 jekyll/builder jekyll serve --drafts
