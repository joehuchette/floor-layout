using FloorLayout, JuMP, CPLEX

const β = 5

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

type Trial
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

U      = Trial(Unary(),         [])
Up     = Trial(Unary(),         lit_cuts)
BLDP1  = Trial(BinaryGray(),    [])
BLDP1p = Trial(BinaryGray(),    lit_cuts)
SP     = Trial(BinaryBlack(),   [SequencePair()])
SPp    = Trial(BinaryBlack(),   [SequencePair();lit_cuts])
SPpVI  = Trial(BinaryBlack(),   [SequencePair();FLP_cuts])
SPpVI3 = Trial(BinaryBlack(),   [SequencePair();FLP_cuts;three_cuts])
RU     = Trial(Partition4Bit(), [])
RUpVI  = Trial(Partition4Bit(), [FLP_cuts;UpperBound108(CutCount{1}())])
RUpVI3 = Trial(Partition4Bit(), [FLP_cuts;three_cuts;UpperBound108(CutCount{1}())])

trials = [U, Up, BLDP1, BLDP1p, SP, SPp, SPpVI, SPpVI3, RU, RUpVI, RUpVI3]

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
