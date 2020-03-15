SYSPKG = YES
REGGAE_PATH = /usr/local/share/reggae
SERVICES = backend https://github.com/bsidesns/backend \
	   frontend https://github.com/bsidesns/frontend


build: up
	@bin/build.sh

publish: build
	@ssh -p 666 bsidesns.org 'cd /usr/cbsd/jails-data/bsidesnsback-data/usr/home/bsidesns/bsidesns && git fetch && git reset --hard origin/master'
	@rsync -P -av --delete-after build/ -e "ssh -p 666" bsidesns.org:/usr/cbsd/jails-data/nginx-data/usr/local/www/bsidesns.org/
	@ssh -t -p 666 bsidesns.org 'sudo cbsd jexec jname=bsidesnsback service supervisord restart'
	@ssh -p 2201 bsidesns.org 'cd /usr/cbsd/jails-data/bsidesnsback-data/usr/home/bsidesns/bsidesns && git fetch && git reset --hard origin/master'
	@rsync -P -av --delete-after build/ -e "ssh -p 2201" bsidesns.org:/usr/cbsd/jails-data/nginx-data/usr/local/www/bsidesns.org/
	@ssh -t -p 2201 bsidesns.org 'sudo cbsd jexec jname=bsidesnsback service supervisord restart'

shell: up
	@${MAKE} ${MFLAGS} -C services/backend shell

do_devel: up
.if defined(service)
.if defined(offline)
	@${MAKE} ${MAKEFLAGS} -C services/${service} devel offline=${offline}
.else
	@${MAKE} ${MAKEFLAGS} -C services/${service} devel
.endif
.else
.if defined(offline)
	@env OFFLINE=${offline} SYSPKG=${SYSPKG} bin/devel.sh reggae
.else
	@env SYSPKG=${SYSPKG} bin/devel.sh reggae
.endif
.endif


.include <${REGGAE_PATH}/mk/project.mk>
