#!bin/bash

excutedate=`date "+20%y%m%d-%H%M%S"`
docker stop test-application test-db ; docker rm test-application test-db ; docker ps
docker run -d -e POSTGRES_USER=odoo -e POSTGRES_PASSWORD=odoo --name test-db dev/postgres:testdata
docker run -d -t -p 9069:8069 --name test-application --link test-db:db dev/backend /home/backend/start.sh
export cucumber_api_verbose=true
export test_ip=localhost
export test_port=9069
sleep 5
curl -L http://$test_ip:9069
bundle exec ruby generate_smoke_feature.rb
bundle exec cucumber -f Cucumber::Formatter::HtmlLink -o result.html features/smoke.feature
