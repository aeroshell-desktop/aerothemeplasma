#!/bin/bash
# Version 9
# Requires plasmoidviewer v5.13.0

function checkIfLangInstalled {
	if [ -x "$(command -v dpkg)" ]; then
		dpkg -l ${1} >/dev/null 2>&1 || ( \
			echo -e "${1} not installed.\nInstalling now before continuing.\n" \
			; sudo apt install ${1} \
		) || ( \
			echo -e "\nError trying to install ${1}\nPlease run 'sudo apt install ${1}'\n" \
			; exit 1 \
		)
	elif [ -x "$(command -v pacman)" ]; then
		# TODO: run `locale -a` and check if the locale is enabled.
		if false; then
			# https://wiki.archlinux.org/index.php/Locale
			# Uncomment the locale in /etc/locale.gen
			# Then run `locale-gen`
			echo -e "\nPlease install this locale in System Settings first.\n"
			exit 1
		else
			echo ""
		fi
	else
		echo -e "\nPackage manager not recognized. If the widget is not translated, please install the package '${1}'\n"
	fi
}

langInput="${1}"
lang=""
languagePack=""

if [[ "$langInput" =~ ":" ]]; then # String contains a colon so assume it's a locale code.
	lang="${langInput}"
	IFS=: read -r l1 l2 <<< "${lang}"
	languagePack="language-pack-${l2}"
fi

# https://stackoverflow.com/questions/3191664/list-of-all-locales-and-their-short-codes/28357857#28357857
declare -a langArr=(
	"af_ZA:af:Afrikaans (South Africa)"
	"ak_GH:ak:Akan (Ghana)"
	"am_ET:am:Amharic (Ethiopia)"
	"ar_EG:ar:Arabic (Egypt)"
	"as_IN:as:Assamese (India)"
	"az_AZ:az:Azerbaijani (Azerbaijan)"
	"be_BY:be:Belarusian (Belarus)"
	"bem_ZM:bem:Bemba (Zambia)"
	"bg_BG:bg:Bulgarian (Bulgaria)"
	"bo_IN:bo:Tibetan (India)"
	"bs_BA:bs:Bosnian (Bosnia and Herzegovina)"
	"ca_ES:ca:Catalan (Spain)"
	"chr_US:ch:Cherokee (United States)"
	"cs_CZ:cs:Czech (Czech Republic)"
	"cy_GB:cy:Welsh (United Kingdom)"
	"da_DK:da:Danish (Denmark)"
	"de_DE:de:German (Germany)"
	"el_GR:el:Greek (Greece)"
	"es_MX:es:Spanish (Mexico)"
	"et_EE:et:Estonian (Estonia)"
	"eu_ES:eu:Basque (Spain)"
	"fa_IR:fa:Persian (Iran)"
	"ff_SN:ff:Fulah (Senegal)"
	"fi_FI:fi:Finnish (Finland)"
	"fo_FO:fo:Faroese (Faroe Islands)"
	"fr_CA:fr:French (Canada)"
	"ga_IE:ga:Irish (Ireland)"
	"gl_ES:gl:Galician (Spain)"
	"gu_IN:gu:Gujarati (India)"
	"gv_GB:gv:Manx (United Kingdom)"
	"ha_NG:ha:Hausa (Nigeria)"
	"he_IL:he:Hebrew (Israel)"
	"hi_IN:hi:Hindi (India)"
	"hr_HR:hr:Croatian (Croatia)"
	"hu_HU:hu:Hungarian (Hungary)"
	"hy_AM:hy:Armenian (Armenia)"
	"id_ID:id:Indonesian (Indonesia)"
	"ig_NG:ig:Igbo (Nigeria)"
	"is_IS:is:Icelandic (Iceland)"
	"it_IT:it:Italian (Italy)"
	"ja_JP:ja:Japanese (Japan)"
	"ka_GE:ka:Georgian (Georgia)"
	"kk_KZ:kk:Kazakh (Kazakhstan)"
	"kl_GL:kl:Kalaallisut (Greenland)"
	"km_KH:km:Khmer (Cambodia)"
	"kn_IN:kn:Kannada (India)"
	"ko_KR:ko:Korean (South Korea)"
	"ko_KR:ko:Korean (South Korea)"
	"lg_UG:lg:Ganda (Uganda)"
	"lt_LT:lt:Lithuanian (Lithuania)"
	"lv_LV:lv:Latvian (Latvia)"
	"mg_MG:mg:Malagasy (Madagascar)"
	"mk_MK:mk:Macedonian (Macedonia)"
	"ml_IN:ml:Malayalam (India)"
	"mr_IN:mr:Marathi (India)"
	"ms_MY:ms:Malay (Malaysia)"
	"mt_MT:mt:Maltese (Malta)"
	"my_MM:my:Burmese (Myanmar [Burma])"
	"nb_NO:nb:Norwegian Bokmål (Norway)"
	"ne_NP:ne:Nepali (Nepal)"
	"nl_NL:nl:Dutch (Netherlands)"
	"nn_NO:nn:Norwegian Nynorsk (Norway)"
	"om_ET:om:Oromo (Ethiopia)"
	"or_IN:or:Oriya (India)"
	"pa_PK:pa:Punjabi (Pakistan)"
	"pl_PL:pl:Polish (Poland)"
	"ps_AF:ps:Pashto (Afghanistan)"
	"pt_BR:pt:Portuguese (Brazil)"
	"ro_RO:ro:Romanian (Romania)"
	"ru_RU:ru:Russian (Russia)"
	"rw_RW:rw:Kinyarwanda (Rwanda)"
	"si_LK:si:Sinhala (Sri Lanka)"
	"sk_SK:sk:Slovak (Slovakia)"
	"sl_SI:sl:Slovenian (Slovenia)"
	"so_SO:so:Somali (Somalia)"
	"sq_AL:sq:Albanian (Albania)"
	"sr_RS:sr:Serbian (Serbia)"
	"sv_SE:sv:Swedish (Sweden)"
	"sw_KE:sw:Swahili (Kenya)"
	"ta_IN:ta:Tamil (India)"
	"te_IN:te:Telugu (India)"
	"th_TH:th:Thai (Thailand)"
	"ti_ER:ti:Tigrinya (Eritrea)"
	"to_TO:to:Tonga (Tonga)"
	"tr_TR:tr:Turkish (Turkey)"
	"uk_UA:uk:Ukrainian (Ukraine)"
	"ur_IN:ur:Urdu (India)"
	"uz_UZ:uz:Uzbek (Uzbekistan)"
	"vi_VN:vi:Vietnamese (Vietnam)"
	"yo_NG:yo:Yoruba (Nigeria)"
	"yo_NG:yo:Yoruba (Nigeria)"
	"yue_HK:yu:Cantonese (Hong Kong)"
	"zh_CN:zh:Chinese (China)"
	"zu_ZA:zu:Zulu (South Africa)"
)

for i in "${langArr[@]}"; do
	IFS=: read -r l1 l2 l3 <<< "$i"
	if [ "$langInput" == "$l2" ]; then
		lang="${l1}:${l2}"
		languagePack="language-pack-${l2}"
	fi
done

if [ -z "$lang" ]; then
	echo "plasmoidlocaletest doesn't recognize the language '$lang'"
	echo "Eg:"
	scriptcmd='sh ./plasmoidlocaletest'
	for i in "${langArr[@]}"; do
		IFS=: read -r l1 l2 l3 <<< "$i"
		echo "    ${scriptcmd} ${l2}     | ${l3}"
	done
	echo ""
	echo "Or use a the full locale code:"
	echo "    ${scriptcmd} ar_EG:ar"
	exit 1
fi

IFS=: read -r l1 l2 <<< "${lang}"
l1="${l1}.UTF-8"

# Check if language is installed
if [ ! -z "$languagePack" ]; then
	if [ "$lang" == "zh_CN:zh" ]; then languagePack="language-pack-zh-hans"
	fi

	checkIfLangInstalled "$languagePack" || exit 1
fi


echo "LANGUAGE=\"${lang}\""
echo "LANG=\"${l1}\""

scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
packageDir="${scriptDir}/.."

# Build local translations for plasmoidviewer
sh "${scriptDir}/build"

LANGUAGE="${lang}" LANG="${l1}" LC_TIME="${l1}" QML_DISABLE_DISK_CACHE=true plasmoidviewer -a "$packageDir" -l topedge -f horizontal -x 0 -y 0
