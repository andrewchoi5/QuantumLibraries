﻿// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Canon {
    open Microsoft.Quantum.Primitive;

    /// # Summary
    /// Apply the Approximate Quantum Fourier Transform (AQFT) to a quantum register.
    ///
    /// # Input
    /// ## a
    /// approximation parameter which determines at which level the controlled Z-rotations that 
    /// occur in the QFT circuit are pruned.
    /// ## qs
    /// quantum register of n qubits to which the approximate quantum Fourier transform is applied.
    ///
    /// # Remarks
    /// AQFT requires Z-rotation gates of the form 2π/2ᵏ and Hadamard gates. The input and output
    /// are assumed to be encoded in big endian encoding. 
    /// The approximation parameter a determines the pruning level of the Z-rotations, i.e.,
    /// a ∈ {0..n} and all Z-rotations 2π/2ᵏ where k>a are 
    /// removed from the QFT circuit. It is known that for k >= log₂(n)+log₂(1/ε)+3 
    /// one can bound ||QFT-AQFT||<ε. 
    /// 
    /// # References 
    /// - [ *M. Roetteler, Th. Beth*,
    ///      Appl. Algebra Eng. Commun. Comput.
    ///      19(3): 177-193 (2008) ](http://doi.org/10.1007/s00200-008-0072-2)
    /// - [ *D. Coppersmith* arXiv:quant-ph/0201067v1 ](https://arxiv.org/abs/quant-ph/0201067)
    operation ApproximateQFT ( a: Int, qs: BigEndian) : () {
        body {
            
            let nQubits = Length(qs);
            AssertBoolEqual( nQubits > 0, true, "`Length(qs)` must be least 1" );
            AssertBoolEqual(
                (a > 0) && ( a <= nQubits ), true,
                "`a` must be positive and less than `Length(qs)`" );

            for (i in 0 .. (nQubits - 1) ) {
                for (j in 0..(i-1)) {
                    if ( (i-j) < a ) {
                        (Controlled R1Frac)( [qs[i]], (1, i - j, qs[j]) );
                    }
                }
                H(qs[i]);
            }

            // Apply the bit reversal permutation to the quantum register as
            // a side effect, such that we enforce the invariants specified
            // by the BigEndian UDT.
            SwapReverseRegister(qs);
        }

        adjoint auto
        controlled auto
        controlled adjoint auto
    }

    /// # Summary
    /// Performs the quantum Fourier transform on an quantum register containing an 
    /// integer in the big-endian representation.
    ///
    /// # Input
    /// ## qs
    /// quantum register of n qubits to which the quantum Fourier transform is applied
    ///
    /// # Remarks
    /// The input and output are assumed to be in big endian encoding.
    /// 
    /// # See Also 
    /// - @"microsoft.quantum.canon.approximateqft"
    /// - @"microsoft.quantum.canon.qftle"
    operation QFT ( qs : BigEndian ) : () {
        body {
            ApproximateQFT(Length(qs), qs);
        }
        adjoint auto
        controlled auto
        controlled adjoint auto
    }

    /// # Summary
    /// Little-endian version of QFT. 
    ///
    /// # Input
    /// ## target 
    /// Quantum register to which Fourier transform is applied
    ///
    /// # See Also
    /// - @"microsoft.quantum.canon.qft"
    operation QFTLE( target : LittleEndian ) : () {
        body {
            ApplyReversedOpBigEndianCA(QFT,target);
        }
        adjoint auto
        controlled auto
        controlled adjoint auto
    }
}
