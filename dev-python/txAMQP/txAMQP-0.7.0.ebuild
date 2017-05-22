# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python2_7 )
inherit distutils-r1

MY_P=${PN,,}-${PV}
DESCRIPTION="Python library for communicating with AMQP peers using Twisted"
HOMEPAGE="https://github.com/txamqp/txamqp"
# pypi tarball misses necessary test files
SRC_URI="https://github.com/txamqp/txamqp/archive/${PV}.tar.gz -> ${MY_P}.tar.gz"

LICENSE="Apache-2.0"
KEYWORDS="~amd64 ~x86 ~x64-solaris"
SLOT="0"
IUSE="test"

RDEPEND="dev-python/twisted-core[${PYTHON_USEDEP}]"
DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]
	test? (
		${RDEPEND}
		net-misc/rabbitmq-server
	)"

S=${WORKDIR}/${MY_P}

# Tests connect to the system rabbitmq server
# TODO: figure out how to start an isolated instance
RESTRICT="test"

python_test() {
	cd src || die
	# tests look for those files relatively to modules
	cp -r specs "${BUILD_DIR}"/lib || die

	TXAMQP_BROKER=RABBITMQ trial txamqp
	local ret=${?}

	# avoid installing spec files
	rm -r "${BUILD_DIR}"/lib/specs || die

	[[ ${ret} == 0 ]] || die "Tests failed with ${EPYTHON}"
}

python_install_all() {
	local DOCS=( doc/* )

	distutils-r1_python_install_all
}
