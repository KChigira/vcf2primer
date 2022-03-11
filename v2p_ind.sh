#! /bin/bash
function usage {
  cat <<EOM
Usage: $(basename "$0") -R referance_genome.fasta -I input.vcf [OPTION]...
  -h Display help
  -R [Referance Genome].fasta
  -I [Input VCF File].vcf
  -n sample_name                default:"sample"
  -d minimum_sequence_depth     default:15
  -p maximum_sequence_depth     default:60
  -l minimum_indel_length       default:11
  -g maximum_indel_length       default:50
  -b minimum_length_between_2_variants    default:150
  -s scope where primer designed          default:140
  -m margin of target sequence where primers don't locate    default:5
  -t [primer3 template file]    default:"template_ind.txt"
EOM
  exit 2
}

REF="f"
VCF="f"
NAME="sample"
MIN_DEP=15
MAX_DEP=60
MIN_LEN=11
MAX_LEN=50
BETWEEN=150
SCOPE=140
MARGIN=5
TEMP="template_ind.txt"

while getopts ":R:I:n:d:p:l:g:b:s:m:t:h" optKey; do
  case "$optKey" in
    R) REF=${OPTARG};;
    I) VCF=${OPTARG};;
    n) NAME=${OPTARG};;
    d) MIN_DEP=${OPTARG};;
    p) MAX_DEP=${OPTARG};;
    l) MIN_LEN=${OPTARG};;
    g) MAX_LEN=${OPTARG};;
    b) BETWEEN=${OPTARG};;
    s) SCOPE=${OPTARG};;
    m) MARGIN=${OPTARG};;
    t) TEMP=${OPTARG};;
    '-h'|'--help'|* ) usage;;
  esac
done

#check
[ ! -e ${REF} ] && usage
[ ! -e ${VCF} ] && usage
[ ${NAME} == "" ] && usage
expr $MIN_DEP + 1 >&/dev/null
[ $? -ge 2 ] && usage
expr $MAX_DEP + 1 >&/dev/null
[ $? -ge 2 ] && usage
expr $MIN_LEN + 1 >&/dev/null
[ $? -ge 2 ] && usage
expr $MAX_LEN + 1 >&/dev/null
[ $? -ge 2 ] && usage
expr $BETWEEN + 1 >&/dev/null
[ $? -ge 2 ] && usage
expr $SCOPE + 1 >&/dev/null
[ $? -ge 2 ] && usage
expr $MARGIN + 1 >&/dev/null
[ $? -ge 2 ] && usage

CURRENT=$(pwd)
cd $(dirname $0)
[ ! -e "temp/${TEMP}" ] && usage

ID=""
CNT=0

perl perl/select_ind.pl ${CURRENT}/${VCF} ${CURRENT}/${NAME}_selected.vcf \
                        ${MIN_DEP} ${MAX_DEP} ${MIN_LEN} ${MAX_LEN} \
                        ${BETWEEN}
if test $? -ne 0 ; then
  echo "Selecting variants was failed."
  exit 1
fi

perl perl/make_samtools_data.pl ${CURRENT}/${NAME}_selected.vcf \
                                ${CURRENT}/${NAME}_list_samtools.txt \
                                ${SCOPE}
if test $? -ne 0 ; then
  echo "Making data for extracting sequence was failed."
  exit 1
fi

while read line
do
  samtools faidx -n 10000 ${CURRENT}/${REF} ${line} \
            >> ${CURRENT}/${NAME}_sequences.txt
  if test $? -ne 0 ; then
    echo "Extracting sequence from refernce was failed."
    exit 1
  fi
done < ${CURRENT}/${NAME}_list_samtools.txt
echo 'Extracting sequence from refernce has done.'

while read line
do
  if test $((${CNT} % 2)) -eq 0 ; then
    ID=${line}
  else
    perl perl/make_format.pl ${ID} ${line} "temp/${TEMP}" \
                             ${SCOPE} ${MARGIN} \
                             ${CURRENT}/format_for_primer3.txt

    primer3_core --output ${CURRENT}/primer3_result.txt \
                 ${CURRENT}/format_for_primer3.txt
    if test $? -ne 0 ; then
      echo "Make primer was failed."
      exit 1
    fi

    perl perl/make_table.pl ${CURRENT}/primer3_result.txt \
                       ${CURRENT}/${NAME}_primers.tsv

  fi

  CNT=$((${CNT} + 1))

done < ${CURRENT}/${NAME}_sequences.txt

perl perl/make_summary.pl ${CURRENT}/${NAME}_selected.vcf \
                          ${CURRENT}/${NAME}_summary.tsv

[ -e "${CURRENT}/format_for_primer3.txt" ] && rm ${CURRENT}/format_for_primer3.txt
[ -e "${CURRENT}/primer3_result.txt" ] && rm ${CURRENT}/primer3_result.txt

echo 'All done.'
