AttachSpec("../../endomorphisms/magma/spec");
SetVerbose("EndoCheck", 3);

F := Rationals();
R<x> := PolynomialRing(F);
fX := (x^2 + x)^3 + (x^2 + x) + 1;
X := HyperellipticCurve(fX);
P0s := [ X ! [0, 1, 1], X ! [1, 1, 0] ];

fY := x^3 + x + 1;
Y := HyperellipticCurve(fY);
Q0s := [ Y ! [0, 1, 1], Y ! [1, 0, 0] ];

M := Matrix(F, [
[1, 2]
]);

for P0 in P0s do
    for Q0 in Q0s do
        print "";
        print "Field:";
        print F;
        print "Curve X:";
        print X;
        print "Point P0:";
        print P0;
        print "Curve Y:";
        print Y;
        print "Point Q0:";
        print Q0;
        print "Check that base point is not Weierstrass:", not IsWeierstrassPlace(Place(Q0));
        print "Tangent representation:";
        print M;

        print "Calculating Cantor representation...";
        time test, fs := CantorFromMatrixSplit(X, P0, Y, Q0, M : LowerBound := 1);
        R<x,y> := Parent(fs[1]);
        print fs;

        R<x,y> := PolynomialRing(F, 2);
        K := FieldOfFractions(R);

        /* Check that the answer is a projection before transformation: */
        /*
        fX := R ! DefiningEquation(X`U); fY := R ! DefiningEquation(Y`U);
        fs := [ -fs[1], fs[2] ];
        IX := ideal<R | fX>;
        print fs;
        print fY;
        print "Well-defined?", R ! Numerator(K ! Evaluate(R ! fY, fs)) in IX;
        */

        /* Check that the answer is a projection after transformation, by hand: */
        /*
        fX := R ! DefiningEquation(AffinePatch(X, 1)); fY := R ! DefiningEquation(AffinePatch(Y, 1));
        fs := [ -fs[1], fs[2] ];
        fs := [ 1 / fs[2], fs[1] / fs[2]^2 ];
        fY := Evaluate(fY, [ y, x ]);
        fY := y^2 - (x^3 + x + 1);
        IX := ideal<R | fX>;
        print fs;
        print fY;
        print "Well-defined?", R ! Numerator(K ! Evaluate(R ! fY, fs)) in IX;
        */

        /* Check that the answer is a projection after transformation, automatic: */
        fX := R ! DefiningEquation(AffinePatch(X, 1)); fY := R ! DefiningEquation(AffinePatch(Y, 1));
        IX := ideal<R | fX>;
        print "Well-defined?", R ! Numerator(K ! Evaluate(R ! fY, fs)) in IX;

        /* Check that the action on differentials is correct: */
        fX := R ! DefiningEquation(AffinePatch(X, 1));
        fY := R ! DefiningEquation(AffinePatch(Y, 1));
        dx := K ! 1;
        dy := K ! -Derivative(fX, 1)/Derivative(fX, 2);
        ev := ((K ! Derivative(fs[1], 1))*dx + (K ! Derivative(fs[1], 2))*dy) / (K ! (2*fs[2]));
        print "Correct pullback?", R ! Numerator(K ! (ev - &+[ M[1,i]*x^(i - 1) : i in [1..Genus(X)] ]/(2*y))) in IX;

        AX := AffinePatch(X, 1); AY := AffinePatch(Y, 1);
        KX := FunctionField(AX); KY := FunctionField(AY);
        m := map<AX -> AY | fs >;
        print "Degree:", Degree(ProjectiveClosure(m));
    end for;
end for;

exit;
