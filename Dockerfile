FROM jekyll/jekyll
WORKDIR /srv/jekyll
ADD . .
RUN bundle install