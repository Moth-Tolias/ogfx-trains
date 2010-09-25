
Name:           %{dz_repo}
Version:        %{dz_version} 
Release:        %{_vendor}%{?suse_version} 
Summary:        DevZone Projects Compiler 

Group:          Amusements/Games
License:        GPLv2
URL:            http://dev.openttdcoop.org

Source0:        %{name}-%{version}.tar

BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-buildroot

BuildArch:      noarch

BuildRequires:  mercurial p7zip grfcodec unix2dos grf2html

%description
Build script for #openttdcoop DevZone projects

%prep
%setup -qn %{name}
cd ..
mv %{name} %{name}.hg
mkdir %{name}
cd %{name}.hg

make %{?_smp_mflags} bundle_src bundle_zip ZIP="7za a" ZIP_FLAGS="-tzip -mx9" 1>../%{name}/%{name}-%{version}-build.log 2>../%{name}/%{name}-%{version}-build.err.log

mv *.tar.gz *.zip ../%{name} 1>>../%{name}/%{name}-%{version}-build.log 2>>../%{name}/%{name}-%{version}-build.err.log
cd ../%{name} 1>>../%{name}/%{name}-%{version}-build.log 2>>../%{name}/%{name}-%{version}-build.err.log
tar -xz < `ls *-source.tar.gz` 1>>%{name}-%{version}-build.log 2>>%{name}-%{version}-build.err.log
mv *-source/* . 1>>%{name}-%{version}-build.log 2>>%{name}-%{version}-build.err.log
rmdir *-source 1>>%{name}-%{version}-build.log 2>>%{name}-%{version}-build.err.log

%build
#we have unix2dos installed for the zip, but now, we like to build without
#docs aren't built by default
make %{?_smp_mflags} docs UNIX2DOS= 1>>%{name}-%{version}-build.log 2>>%{name}-%{version}-build.err.log
#cleanup, because we don't make a fresh chroot fro every build
rm -r ~/.nforenum
grf2html -o grf2html *.grf 1>%{name}-%{version}-grf2html.log 2>&1

%install
make install INSTALL_DIR=%{buildroot}%{_datadir}/openttd/data

%check
make check

%clean
#rm -rf %{buildroot} 

%files
%defattr(-,root,root,-)
%dir %{_datadir}/openttd
%dir %{_datadir}/openttd/data
%doc %{_datadir}/openttd/data/changelog.txt
%doc %{_datadir}/openttd/data/license.txt
%{_datadir}/openttd/data/ogfx1_base.grf
%{_datadir}/openttd/data/ogfxc_arctic.grf
%{_datadir}/openttd/data/ogfxe_extra.grf
%{_datadir}/openttd/data/ogfxh_tropical.grf
%{_datadir}/openttd/data/ogfxi_logos.grf
%{_datadir}/openttd/data/ogfxt_toyland.grf
%{_datadir}/openttd/data/opengfx.obg
%doc %{_datadir}/openttd/data/readme.txt

%changelog
