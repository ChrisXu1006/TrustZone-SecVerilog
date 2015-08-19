; this part encodes a partial order on labels
(declare-sort Label)
(declare-fun leq (Label Label) Bool)
(declare-fun join (Label Label) Label)
(declare-fun meet (Label Label) Label)
(assert (forall ((x Label)) (leq x x)))
(assert (forall ((x Label) (y Label) (z Label)) (implies (and (leq x y) (leq y z)) (leq x z))))
(assert (forall ((x Label) (y Label)) (implies (and (leq x y) (leq y x)) (= x y))))

; axioms for join
(assert (forall ((x Label) (y Label) (z Label)) (implies (leq (join x y) z) (and (leq x z) (leq y z)))))
(assert (forall ((x Label) (y Label) (z Label)) (implies (and (leq x z) (leq y z)) (leq (join x y) z))))
(assert (forall ((x Label) (y Label)) (and (leq x (join x y)) (leq y (join x y)))))
(assert (forall ((x Label) (y Label)) (= (join x y) (join y x))))

; axioms for meet
(assert (forall ((x Label) (y Label) (z Label)) (implies (leq x (meet y z)) (and (leq x y) (leq x z)))))
(assert (forall ((x Label) (y Label) (z Label)) (implies (and (leq x y) (leq x z)) (leq x (meet y z)))))
(assert (forall ((x Label) (y Label)) (and (leq (meet x y) x) (leq (meet x y) y))))
(assert (forall ((x Label) (y Label)) (= (meet x y) (meet y x))))

; lattice elements
(declare-fun LOW () Label)
(declare-fun HIGH () Label)
(declare-fun D1 () Label)
(declare-fun D2 () Label)

; lattice structure
(assert (forall ((x Label)) (leq LOW x)))
(assert (forall ((x Label)) (leq x HIGH)))
(assert (not (= HIGH LOW))) ; the lattice cannot clapse

; variables to be solved
(declare-fun in0_domain () Int)
(assert (<= 0  in0_domain))
(assert (<= in0_domain 1))
(declare-fun in1_domain () Int)
(assert (<= 0  in1_domain))
(assert (<= in1_domain 1))
(declare-fun in2_domain () Int)
(assert (<= 0  in2_domain))
(assert (<= in2_domain 1))

; function that maps 0 to LOW; 1 to HIGH
(declare-fun LH (Int) Label)
(assert (= (LH 0) LOW))
(assert (= (LH 1) HIGH))

; function that maps 0 to D1; 1 to D2; 2 to LOW; 3 to HIGH
(declare-fun Domain (Int) Label)
(assert (= (Domain 0) D1))
(assert (= (Domain 1) D2))
(assert (= (Domain 2) LOW))
(assert (= (Domain 3) HIGH))

; function that maps 0 to D1; 1 to D2; 2 to LOW; 3 to HIGH
(declare-fun Control (Int) Label)
(assert (= (Control 0) D1))
(assert (= (Control 1) D2))
(assert (= (Control 2) LOW))
(assert (= (Control 3) HIGH))

; function for data signals
(declare-fun Data (Int) Label)
(assert (= (Data 0) D1))
(assert (= (Data 1) D2))
(assert (= (Data 2) LOW))
(assert (= (Data 3) HIGH))

; function for control signals
(declare-fun Ctrl (Int) Label)
(assert (= (Ctrl 0) D1))
(assert (= (Ctrl 1) D2))
(assert (= (Ctrl 2) LOW))
(assert (= (Ctrl 3) HIGH))

; function for NS signals
(declare-fun Ns (Int) Label)
(assert (= (Ns 0) LOW))
(assert (= (Ns 1) LOW))
(assert (= (Ns 2) LOW))
(assert (= (Ns 3) HIGH))

; function for address signals
(declare-fun Addr (Int) Label)
(assert (= (Addr 0) LOW))
(assert (= (Addr 1) LOW))
(assert (= (Addr 2) LOW))
(assert (= (Addr 3) HIGH))

; assertions to be verified

(push)
(assert  (not(leq (join (join (join (Ctrl in2_domain) (Ctrl in1_domain)) (Ctrl in0_domain)) (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain))))  (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain))))))    ; assign beg = (((req2)|(req1))|(req0))&(~(lcomreq)) @./vc-arbiter.v:61
(check-sat)
(pop)


(push)
(assert  (not(leq (join (join (join (Ctrl in2_domain) (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain)))) (join (Ctrl in1_domain) (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain))))) (join (Ctrl in0_domain) (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain)))))  (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain))))))    ; assign lcomreq = (((req2)&(lgnt2))|((req1)&(lgnt1)))|((req0)&(lgnt0)) @./vc-arbiter.v:72
(check-sat)
(pop)


(push)
(assert  (not(leq (join (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain))) (join (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain))) (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain)))))  (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain))))))    ; assign lgnt = {(lgnt0)|(lgnt2), (lgnt0)|(lgnt1)} @./vc-arbiter.v:79
(check-sat)
(pop)


(push)
(assert  (not(leq (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain)))  (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain))))))    ; assign comreq = lcomreq @./vc-arbiter.v:96
(check-sat)
(pop)


(push)
(assert  (not(leq (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain)))  (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain))))))    ; assign gnt = lgnt @./vc-arbiter.v:97
(check-sat)
(pop)


(push)
(assert  (not(leq (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain)))  (Ctrl in2_domain))))    ; assign gnt2 = lgnt2 @./vc-arbiter.v:101
(check-sat)
(pop)


(push)
(assert  (not(leq (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain)))  (Ctrl in1_domain))))    ; assign gnt1 = lgnt1 @./vc-arbiter.v:102
(check-sat)
(pop)


(push)
(assert  (not(leq (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain)))  (Ctrl in0_domain))))    ; assign gnt0 = lgnt0 @./vc-arbiter.v:103
(check-sat)
(pop)


(push)
(assert  (not(leq LOW  (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain))))))    ; lgnt0 <= 0 @./vc-arbiter.v:40
(check-sat)
(pop)


(push)
(assert  (not(leq LOW  (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain))))))    ; lgnt1 <= 0 @./vc-arbiter.v:41
(check-sat)
(pop)


(push)
(assert  (not(leq LOW  (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain))))))    ; lgnt2 <= 0 @./vc-arbiter.v:42
(check-sat)
(pop)


(push)
(assert  (not(leq (join (join (join (join (join (join (join (join (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain))) (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain)))) (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain)))) (Ctrl in2_domain)) (Ctrl in1_domain)) (Ctrl in0_domain)) (join (join (join (join (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain))) (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain)))) (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain)))) (Ctrl in2_domain)) (Ctrl in0_domain))) (join (join (join (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain))) (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain)))) (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain)))) (Ctrl in0_domain))) (join (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain))) (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain)))))  (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain))))))    ; lgnt0 <= ((((((((~(lcomreq))&(~(lmask1)))&(~(lmask0)))&(~(req2)))&(~(req1)))&(req0))|(((((~(lcomreq))&(~(lmask1)))&(lmask0))&(~(req2)))&(req0)))|((((~(lcomreq))&(lmask1))&(lmask0))&(req0)))|((lcomreq)&(lgnt0)) @./vc-arbiter.v:44
(check-sat)
(pop)


(push)
(assert  (not(leq (join (join (join (join (join (join (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain))) (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain)))) (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain)))) (Ctrl in1_domain)) (join (join (join (join (join (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain))) (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain)))) (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain)))) (Ctrl in2_domain)) (Ctrl in1_domain)) (Ctrl in0_domain))) (join (join (join (join (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain))) (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain)))) (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain)))) (Ctrl in1_domain)) (Ctrl in0_domain))) (join (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain))) (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain)))))  (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain))))))    ; lgnt1 <= ((((((~(lcomreq))&(~(lmask1)))&(~(lmask0)))&(req1))|((((((~(lcomreq))&(~(lmask1)))&(lmask0))&(~(req2)))&(req1))&(~(req0))))|(((((~(lcomreq))&(lmask1))&(lmask0))&(req1))&(~(req0))))|((lcomreq)&(lgnt1)) @./vc-arbiter.v:48
(check-sat)
(pop)


(push)
(assert  (not(leq (join (join (join (join (join (join (join (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain))) (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain)))) (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain)))) (Ctrl in2_domain)) (Ctrl in1_domain)) (join (join (join (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain))) (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain)))) (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain)))) (Ctrl in2_domain))) (join (join (join (join (join (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain))) (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain)))) (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain)))) (Ctrl in2_domain)) (Ctrl in1_domain)) (Ctrl in0_domain))) (join (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain))) (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain)))))  (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain))))))    ; lgnt2 <= (((((((~(lcomreq))&(~(lmask1)))&(~(lmask0)))&(req2))&(~(req1)))|((((~(lcomreq))&(~(lmask1)))&(lmask0))&(req2)))|((((((~(lcomreq))&(lmask1))&(lmask0))&(req2))&(~(req1)))&(~(req0))))|((lcomreq)&(lgnt2)) @./vc-arbiter.v:52
(check-sat)
(pop)


(push)
(assert  (not(leq (join (join (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain))) (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain)))) (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain))))  (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain))))))    ; lasmask <= ((beg)&(~(ledge)))&(~(lasmask)) @./vc-arbiter.v:64
(check-sat)
(pop)


(push)
(assert  (not(leq (join (join (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain))) (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain)))) (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain))))  (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain))))))    ; ledge <= (((beg)&(~(ledge)))&(lasmask))|(((beg)&(ledge))&(~(lasmask))) @./vc-arbiter.v:65
(check-sat)
(pop)


(push)
(assert  (not(leq LOW  (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain))))))    ; lmask1 <= 0 @./vc-arbiter.v:86
(check-sat)
(pop)


(push)
(assert  (not(leq LOW  (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain))))))    ; lmask0 <= 0 @./vc-arbiter.v:87
(check-sat)
(pop)


(push)
(assert  (not(leq (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain)))  (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain))))))    ; lmask1 <= lgnt[1] @./vc-arbiter.v:89
(check-sat)
(pop)


(push)
(assert  (not(leq (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain)))  (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain))))))    ; lmask0 <= lgnt[0] @./vc-arbiter.v:90
(check-sat)
(pop)


(push)
(assert  (not(leq (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain)))  (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain))))))    ; lmask1 <= lmask1 @./vc-arbiter.v:92
(check-sat)
(pop)


(push)
(assert  (not(leq (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain)))  (join (Ctrl in0_domain) (join (Ctrl in1_domain) (Ctrl in2_domain))))))    ; lmask0 <= lmask0 @./vc-arbiter.v:93
(check-sat)
(pop)

