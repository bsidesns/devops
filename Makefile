REGGAE_PATH = /usr/local/share/reggae
SERVICES = backend https://github.com/bsidesns/backend \
	   frontend https://github.com/bsidesns/frontend


collect: up
	@bin/build.sh

publish: collect
	@ssh -p 666 bsidesns.org 'cd /usr/cbsd/jails-data/bsidesnsback-data/usr/home/bsidesns/bsidesns && git fetch && git reset --hard origin/master'
	@rsync -P -av --delete-after build/ -e "ssh -p 666" bsidesns.org:/usr/cbsd/jails-data/nginx-data/usr/local/www/bsidesns.org/
	@ssh -t -p 666 bsidesns.org 'sudo cbsd jexec jname=bsidesnsback service supervisord restart'
	@ssh -p 2201 bsidesns.org 'cd /usr/cbsd/jails-data/bsidesnsback-data/usr/home/bsidesns/bsidesns && git fetch && git reset --hard origin/master'
	@rsync -P -av --delete-after build/ -e "ssh -p 2201" bsidesns.org:/usr/cbsd/jails-data/nginx-data/usr/local/www/bsidesns.org/
	@ssh -t -p 2201 bsidesns.org 'sudo cbsd jexec jname=bsidesnsback service supervisord restart'

shell: up
	@${MAKE} ${MFLAGS} -C services/backend shell

.include <${REGGAE_PATH}/mk/project.mk>
