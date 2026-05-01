classdef MotionToMatToMotion < matlab.unittest.TestCase
    properties (TestParameter)
        side = struct('right', true, 'left', false)
    end

    methods (Test)
        function zeros(self, side)
            rxryrz = [0, 0, 0];
            xyz    = [0, 0, 0];
            self.verify_round_trip(rxryrz, xyz, side);
        end

        function flexion(self, side)
            rxryrz = [90, 0, 0];
            xyz    = [0, 0, 0];
            self.verify_round_trip(rxryrz, xyz, side);
        end

        function vv(self, side)
            rxryrz = [0, -5, 0];
            xyz    = [0, 0, 0];
            self.verify_round_trip(rxryrz, xyz, side);
        end
        function ie(self, side)
            rxryrz = [0, 0, 20];
            xyz    = [0, 0, 0];
            self.verify_round_trip(rxryrz, xyz, side);
        end
        function ie_vv(self, side)
            rxryrz = [0, -5, 20];
            xyz    = [0, 0, 0];
            self.verify_round_trip(rxryrz, xyz, side);
        end
        function flex_ie(self, side)
            rxryrz = [10, 0, 20];
            xyz    = [0, 0, 0];
            self.verify_round_trip(rxryrz, xyz, side);
        end
        function flex_vv(self, side)
            rxryrz = [10, -5, 0];
            xyz    = [0, 0, 0];
            self.verify_round_trip(rxryrz, xyz, side);
        end

        function rotations(self, side)
            rxryrz = [10, -5, 20];
            xyz    = [0, 0, 0];
            self.verify_round_trip(rxryrz, xyz, side);
        end

        function translations(self, side)
            rxryrz = [0, 0, 0];
            xyz    = [1.5, -2.3, 0.8];
            self.verify_round_trip(rxryrz, xyz, side);
        end

        function combined(self, side)
            rxryrz = [10, -5, 20];
            xyz    = [1.5, -2.3, 0.8];
            self.verify_round_trip(rxryrz, xyz, side);
        end

    end

    methods (Access = private)
        function verify_round_trip(self, rxryrz, xyz, is_right_knee)
            tol = 1e-5;
            T = findTrackerFixedFrames(rxryrz, xyz);
            motion = rotationsAndTranslations(T, is_right_knee);
            self.verifyEqual(motion.flexion, rxryrz(1), 'AbsTol', tol)
        end
    end
end
