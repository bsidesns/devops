REGGAE_PATH = /usr/local/share/reggae
SERVICES = backend https://github.com/bsidesns/backend \
	   frontend https://github.com/bsidesns/frontend


collect: up
	@bin/collect.sh

publish: collect
	@ssh -p 666 bsidesns.org 'cd /usr/cbsd/jails-data/bsidesnsback-data/usr/home/bsidesns/bsidesns && git fetch && git reset --hard origin/master'
	@rsync -P -rzcv --delete-after build/ -e "ssh -p 666" bsidesns.org:/usr/cbsd/jails-data/nginx-data/usr/local/www/bsidesns.org/
	@ssh -t -p 666 bsidesns.org 'sudo cbsd jexec jname=bsidesnsback supervisorctl restart bsidesns'

shell: up
	@sudo cbsd jexec user=devel jname=bsidesback /usr/src/bin/shell.sh

.include <${REGGAE_PATH}/mk/project.mk>
