using FloorLayout, JuMP, CPLEX

const benchmarks = [:hp,
                    :apte,
                    :xerox,
                    :Camp91,
                    :Bozer97_1,
                    :Bozer97_2,
                    :Bazaraa75_1,
                    :Bazaraa75_2,
                    :Bozer91,
                    :Armour62_1,
                    :Armour62_2]

type Approach
    name::String
    formulation::Formulation
    cuts::Vector{Cut}
end

lit_cuts = [MellerB2(CutCount{2}()),
            MellerV2(CutCount{2}())]

FLP_cuts = [MellerB2(CutCount{1}()),
            MellerV2(CutCount{1}()),
            Objective1(CutCount{1}()),
            Objective2(CutCount{1}()),
            Objective3(CutCount{1}()),
            Objective4(CutCount{1}()),
            ThreeBoxSITB(CutCount{1}()),
            ThreeBoxNonoverlap(CutCount{1}()),
            TightenedSITB(CutCount{1}()),
            UpperBound98(CutCount{1}())]

three_cuts = [ThreeBoxObjective1(CutCount{1}()),
              ThreeBoxObjective2(CutCount{1}()),
              ThreeBoxObjective3(CutCount{1}()),
              ThreeBoxObjective4(CutCount{1}())]

U      = Approach("U",      Unary(),         [])
Up     = Approach("U+",     Unary(),         lit_cuts)
BLDP1  = Approach("BLDP1",  BinaryGray(),    [])
BLDP1p = Approach("BLDP1+", BinaryGray(),    lit_cuts)
SP     = Approach("SP",     BinaryBlack(),   [SequencePair()])
SPp    = Approach("SP+",    BinaryBlack(),   [SequencePair();lit_cuts])
SPpVI  = Approach("SP+VI",  BinaryBlack(),   [SequencePair();FLP_cuts])
SPpVI3 = Approach("SP+VI3", BinaryBlack(),   [SequencePair();FLP_cuts;three_cuts])
RU     = Approach("RU",     Partition4Bit(), [])
RUpVI  = Approach("RU+VI",  Partition4Bit(), [FLP_cuts;UpperBound108(CutCount{1}())])
RUpVI3 = Approach("RU+VI3", Partition4Bit(), [FLP_cuts;three_cuts;UpperBound108(CutCount{1}())])

approaches = [U, Up, BLDP1, BLDP1p, SP, SPp, SPpVI, SPpVI3, RU, RUpVI, RUpVI3]

gap(U,L) = 100*(U-L) / U
const UB = Dict(:hp => 62105.380137346525,
                :apte => 188631.01205865975,
                :xerox => 352437.03500702174,
                :Camp91 => 18522.78606519656,
                :Bozer97_1 => 221.72921422344973,
                :Bazaraa75_1 => 7883.477535194013,
                :Bazaraa75_2 => 13213.552538505586,
                :Bozer97_2 => 131.82764508093453,
                :Bozer91 => 23090.180383161554,
                :Armour62_1 => 22679.140100826913,
                :Armour62_2 => 1.8652032684550043e6)

function jitter_data!(prob::Problem, γ)
    if γ == 0
        return prob
    end
    Lˣ, Lʸ = prob.W, prob.H
    N = prob.N
    β = prob.aspect

    α = copy(prob.area)
    α = α.*(1 + γ*randn(N))
    @assert all(α .>= 0)

    rat = sum(α) / sum(prob.area)

    prob.area = α
    prob.W *= sqrt(rat)
    prob.H *= sqrt(rat)

    prob.wub = min(sqrt(α.*β), Lˣ)
    prob.hub = min(sqrt(α.*β), Lʸ)
    prob.wlb = α ./ prob.wub
    prob.hlb = α ./ prob.hub

    for i in 1:N, j in (i+1):N
        prob.c[i,j] *= (1+γ*randn())
    end
    return prob
end
