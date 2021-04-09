module Client

using Knet, KnetLayers, Morse
using HTTP

import Base: download

# Preprocessing

const charset = "AÂBCDEFGHIÎİJKLMNOPRSTUÛVYZâabcdefghijklmnoprstuûvyzÇÖÜçöüĞğıîŞş"
const lowermap = Dict(split(x)[1] => split(x)[2] for x in split(
"""I ı
İ i
Ö ö
Ü Ü
Ş ş
Ç ç
Ğ ğ
Â â
Û û
Î î""", "\n"))

# const punct_rgx = r"[!\"#$%&\'’\\()*+,-./:;<=>?@\[\]^_`{|}~\d]"
# const charset_rgx = Regex("[^ $(charset)]")
const whitespace_rgx = r"\s+"
const lower_rgx = Regex(join(collect(keys(lowermap)), "|"))

function preprocess(raw::String)
    
    # replace punctuations with spaces
    # raw = replace(raw, punct_rgx => " ")

    # remove any non Turkish characters
    # raw = replace(raw, charset_rgx => "")
    
    # replace multiple white spaces with one space
    raw = replace(raw, whitespace_rgx => " ")
    
    # convert to lower case
    raw = lowercase(replace(raw, lower_rgx => (c) -> lowermap[c]))
    
    return raw
end

# Morse


const server_url ="people.csail.mit.edu/deniz/models/morse/"

function download(model::Type{T}, format; vers="2018", lemma=true, lang="tr") where T
    flang = format === TRDataSet ? string("TR-tr",vers) : string("UD-",lang)
    mname = string("bestModel.MorseModel_lemma_",lemma,"_lang_",flang,"_size_full","_params.jld2")
    lpath = Morse.dir("checkpoints",mname)

    if !isfile(lpath)
        mpath = string(server_url, mname)
        download(mpath,lpath)
    end

    lpath
end

MODEL, VOCAB, PARSER = Nothing, Nothing, Nothing;

function handleAnalyze(req::HTTP.Request, input)
    
    if MODEL === Nothing
        download(TRDataSet)
        global MODEL, VOCAB, PARSER = trained(MorseModel, TRDataSet);
    end

    return Dict("analysis" => MODEL(preprocess(input["text"]), v=VOCAB, p=PARSER))
end

end # module