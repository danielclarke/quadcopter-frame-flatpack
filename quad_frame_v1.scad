bit_radius = 0.4;
fit_tolerance = bit_radius/2;
r_hole = 7.5;
motor_mount_spacing = 18.5;

dim_arm = [sqrt(200)*10+20, 15, 2];
dim_pcb_mount = [64, 64, dim_arm[2], 0.8*64];
dim_pcb_opening = [2*sqrt(2*21*21), dim_arm[1]/2]; 
dim_pcb_slot = [(dim_pcb_mount[0]-dim_pcb_mount[3])/2+fit_tolerance, dim_arm[2]+fit_tolerance];
dim_mount = [dim_arm[2]/2, dim_arm[2]*1.5];
dim_motor_mount = [22, 22, dim_arm[2]];

module half_cnc_square(l, w, r) {
	union() {
		square([l, w], center=true);
		
		translate([l/2 - r*cos(45), r*sin(45) - w/2, 0])
			resize(newsize=[2*r, 2*r, 0])
				circle(r = 1024);

		translate([r*cos(45) - l/2, r*sin(45) - w/2, 0])
			resize(newsize=[2*r, 2*r, 0])
				circle(r = 1024);
	}

}

module full_cnc_square(l, w, r) {
	union() {
		square([l, w], center=true);
		
		translate([-l/2 + r*cos(45), -w/2 + r*sin(45), 0])
			resize(newsize=[2*r, 2*r, 0])
				circle(r = 1024);

		translate([-l/2 + r*cos(45), w/2 - r*sin(45), 0])
			resize(newsize=[2*r, 2*r, 0])
				circle(r = 1024);

		translate([l/2 - r*cos(45), -w/2 + r*sin(45), 0])
			resize(newsize=[2*r, 2*r, 0])
				circle(r = 1024);

		translate([l/2 - r*cos(45), w/2 - r*sin(45), 0])
			resize(newsize=[2*r, 2*r, 0])
				circle(r = 1024);
	}

}

module more_cnc_square(l, w, r) {
	union() {
		half_cnc_square(l, w, r);

		translate([l/2 - r*cos(45), w/2 - r*sin(45), 0])
			resize(newsize=[2*r, 2*r, 0])
				circle(r = 1024);
	}
}

module half_mountless_arm_base(l, w) {
	difference() {
		resize(newsize=[l, w*2, 0]) 
			circle(r=4096);
		
		translate([0, w, 0]) 
			square([l, w*2],center=true);
		
		translate([-l/4, -w/2, 0]) 
			square([l/2, 1.1*w],center=true);

		translate([0, -w/2+w/4, 0])
			square([dim_pcb_opening[0], w/2*1.1], center=true);

		translate([dim_pcb_mount[0]/2-dim_pcb_slot[0]/2 + fit_tolerance/2, 
				-w/2-dim_pcb_slot[1]/2, 0])
			mirror([0, 1, 0])
				rotate([0, 0, 90])
					more_cnc_square(dim_pcb_slot[1], dim_pcb_slot[0], bit_radius);

		for(i=[32:8:70]) {
			translate([l/2*sin(i), -w/2*cos(i), 0])
				resize(newsize=[r_hole*cos(i), r_hole*cos(i), 0])
					circle(r=32);
		}
	}
}

module half_arm_base(l, w) { 
	union() {
		difference() {

			union() {
				half_mountless_arm_base(l, w);

				translate([l/2-dim_mount[0]/2,dim_mount[1]/2,0]) 
					square([dim_mount[0], dim_mount[1]],center=true);

				translate([l/2-motor_mount_spacing - dim_mount[0]/2,dim_mount[1]/2,0]) 
					square([dim_mount[0], dim_mount[1]],center=true);
			
			}

			translate([l/2-(motor_mount_spacing-dim_mount[0])/2-dim_mount[0],dim_mount[1]/2,0]) 
					half_cnc_square(motor_mount_spacing-dim_mount[0], 
						dim_mount[1], bit_radius);

			translate([l/2-motor_mount_spacing-dim_mount[0]-bit_radius*cos(45),
					bit_radius*sin(45),0])
				resize(newsize=[bit_radius*2, bit_radius*2, 0])
					circle(r=128);
		}
		translate([l/2-motor_mount_spacing,dim_mount[1],0]) 
					resize(newsize=[dim_mount[0]*2, dim_mount[0]*2])
						circle(r=1024);

		translate([l/2-dim_mount[0],dim_mount[1],0]) 
					resize(newsize=[dim_mount[0]*2, dim_mount[0]*2])
						circle(r=1024);
	}
}

module arm_base(l, w) {
	union() {
		half_arm_base(l, w);
		mirror([1, 0, 0]) {
			half_arm_base(l, w);
		}
	}
}

module arm_a(l, w) {
	difference() {
		arm_base(l, w);

		translate([0,-w+(w-dim_pcb_opening[1])/4 - 0.05,0]) 
			rotate([0, 0, 180])
				half_cnc_square(dim_arm[2]+fit_tolerance, 
					(w-dim_pcb_opening[1])/2 + 0.1, bit_radius);
	}
}

module arm_b(l, w) {
	rotate([0, 0, 0]) difference() {
		arm_base(l, w);

		translate([0,-w/2-(w-dim_pcb_opening[1])/4 + 0.05,0])
				half_cnc_square(dim_arm[2]+fit_tolerance, 
					(w-dim_pcb_opening[1])/2 + 0.1, bit_radius);
	}
}

module motor_mount() {
	difference() {
		resize(newsize=[22,22,0]) circle(r=128);

		translate([motor_mount_spacing/2,0,0]) 
			full_cnc_square(dim_mount[0]*2, dim_mount[0]*2, bit_radius);
		translate([-motor_mount_spacing/2,0,0]) 
			full_cnc_square(dim_mount[0]*2, dim_mount[0]*2, bit_radius);

		resize(newsize=[3,3,0]) circle(r=128);
		translate([8.5*cos(30),8.5*sin(30),0]) resize(newsize=[3,3,0]) circle(r=128);
		translate([8.5*cos(150),8.5*sin(150),0]) resize(newsize=[3,3,0]) circle(r=128);
		translate([8.5*cos(270),8.5*sin(270),0]) resize(newsize=[3,3,0]) circle(r=128);
	}
}

module pcb_mount() {
	difference() {

		resize(newsize=[dim_pcb_mount[0], dim_pcb_mount[1], 0])
			circle(r=128);
		resize(newsize=[dim_pcb_mount[3], dim_pcb_mount[3], 0])
			circle(r=128);

		translate([22,22,0]) resize(newsize=[4,4,0]) circle(r=128);
		translate([22,-22,0]) resize(newsize=[4,4,0]) circle(r=128);
		translate([-22,22,0]) resize(newsize=[4,4,0]) circle(r=128);
		translate([-22,-22,0]) resize(newsize=[4,4,0]) circle(r=128);
	}
}

module flat_pack() {
	translate([sqrt(200)*10/2+11, 80, -dim_arm[2]/2]) {

		translate([-45,-50,0]) rotate([0,0,0]) pcb_mount();
		rotate([0,0,0]) translate([0,-30, 0]) motor_mount();
		rotate([0,0,0]) translate([0,-60, 0]) motor_mount();
		rotate([0,0,0]) translate([30,-30, 0]) motor_mount();
		rotate([0,0,0]) translate([30, -60, 0]) motor_mount();

		translate([0, 0, 0]) arm_a(dim_arm[0], dim_arm[1]);
		translate([0, 20, 0]) arm_b(dim_arm[0], dim_arm[1]);
	}
}

module assembly() {
	translate([0, 0, -1]) linear_extrude(dim_arm[2]) 
		arm_a(dim_arm[0], dim_arm[1]);
	translate([-1, 0, 0]) rotate([0, 90, 0]) linear_extrude(dim_arm[2]) 
		arm_b(dim_arm[0], dim_arm[1]);
	translate([0, dim_mount[1]/2-dim_arm[1]/2-dim_pcb_slot[1]/2, 0]) rotate([90, 0, 0]) 
        linear_extrude(dim_arm[2]) pcb_mount();
    translate([dim_arm[0]/2 - dim_motor_mount[0]/2 + dim_motor_mount[2]/2, dim_arm[2], 0]) 
        rotate([90, 0, 0]) linear_extrude(dim_arm[2]) motor_mount();
    translate([-dim_arm[0]/2 + dim_motor_mount[0]/2 - dim_motor_mount[2]/2, dim_arm[2], 0]) 
        rotate([90, 0, 0]) linear_extrude(dim_arm[2]) motor_mount();
    translate([0, dim_arm[2], -dim_arm[0]/2 + dim_motor_mount[0]/2 - dim_motor_mount[2]/2]) 
        rotate([90, 90, 0]) linear_extrude(dim_arm[2]) motor_mount();
    translate([0, dim_arm[2], dim_arm[0]/2 - dim_motor_mount[0]/2 + dim_motor_mount[2]/2]) 
        rotate([90, 90, 0]) linear_extrude(dim_arm[2]) motor_mount();
}

/*
translate([dim_arm[0]/2+1, dim_arm[1]*2+dim_pcb_mount[0]+1, 0]) {
arm_b(dim_arm[0], dim_arm[1]);

translate([0, -16, 0]) arm_a(dim_arm[0], dim_arm[1]);

translate([-49, -62, 0])
	rotate([0,0,45])
	pcb_mount();

translate([-49,-49,0])
	motor_mount();

translate([-60.5,-69,0])
	motor_mount();

translate([-37.5,-69,0])
	motor_mount();

translate([-9,-43,0])
	motor_mount();
}
*/

assembly()

render();