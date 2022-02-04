module hdmi
#(
	// Default to 640x480
	parameter	VIDEO_ID_CODE = 1,
	
	// The IT Content indicates that the image samples are generated in a framebuffer
	parameter IT_CONTENT = 1'b1,
	
	// Default to minimum bit lengths required to represent positions.
	// Modified these parameters if users have alternate desired bit length
	parameter	BIT_WITDH 	= VIDEO_ID_CODE < 4 ? 10 : VIDEO_ID_CODE == 4 ? 11 : 12,
	parameter BIT_HEIGHT	= VIDEO_ID_CODE == 16 ? 11 : 10,
	
	// Enable this signal to reduce resource usage if users only need output video
	parameter DVI_OUTPUT = 1'b0,
	
	// Specify the refresh rate in Hz users are using for audio calculations
	parameter VIDEO_REFLASH_RATE = 59.94,
	
	// Minumal audio requirements are met: 16-bit or more L-PCM audio at 32 kHz, 44.1 kHz, or 48 kHz
	parameter AUDIO_RATE = 44100,
	
	// Default to 16-bit audio. Can be anywhere from 16-bit to 24-bit
	parameter AUDIO_BIT_WIDTH = 16,
	
	// Starting screen coordinate when module comes out of reset
	parameter	START_X = 0,
	parameter START_Y = 0
)
(
		input		wire				clk_pixel,
		input		wire				clk_pixel_x5,
		input		wire				clk_audio,
		
		// synchronous reset back to 0,0
		input		wire				reset,
		input		wire [23:0]	rgb,
		input		wire [AUDIO_BIT_WIDTH-1:0]	audio_sample_word [1:0],
		
		// these outputs go to hdmi port
		output	wire [2:0]	tmds,
		output	wire				tmds_clock,
		
		// All outputs below this line stay inside the FPGA
		output	wire [BIT_WITDH-1:0]	cx = START_X,
		output	wire [BIT_HEIGHT-1:0]	cy = START_Y,
		
		// The screen is at the upper left corner of the frame
		// 0,0 = 0,0 in video
		output	wire [BIT_WITDH-1:0]	frame_width,
		output	wire [BIT_HEIGHT-1:0]	frame_height,
		output	wire [BIT_WITDH-1:0]	screen_width,
		output	wire [BIT_HEIGHT-1:0]	screen_height
);

	localparam	NUM_CHANNELS = 3;
	wire				hsync;
	wire				vsync;
	
	reg [BIT_WITDH-1:0]		hsync_porch_start, hsync_porch_size;
	reg	[BIT_HEIGHT-1:0]	vsync_porch_start, vsync_porch_size;
	reg	invert;
	
// See CEA-861-D for more specifics formats described below.
generate
    case (VIDEO_ID_CODE)
        1:
        begin
            assign frame_width = 800;
            assign frame_height = 525;
            assign screen_width = 640;
            assign screen_height = 480;
            assign hsync_porch_start = 16;
            assign hsync_porch_size = 96;
            assign vsync_porch_start = 10;
            assign vsync_porch_size = 2;
            assign invert = 1;
            end
        2, 3:
        begin
            assign frame_width = 858;
            assign frame_height = 525;
            assign screen_width = 720;
            assign screen_height = 480;
            assign hsync_porch_start = 16;
            assign hsync_porch_size = 62;
            assign vsync_porch_start = 9;
            assign vsync_porch_size = 6;
            assign invert = 1;
            end
        4:
        begin
            assign frame_width = 1650;
            assign frame_height = 750;
            assign screen_width = 1280;
            assign screen_height = 720;
            assign hsync_porch_start = 110;
            assign hsync_porch_size = 40;
            assign vsync_porch_start = 5;
            assign vsync_porch_size = 5;
            assign invert = 0;
        end
        16, 34:
        begin
            assign frame_width = 2200;
            assign frame_height = 1125;
            assign screen_width = 1920;
            assign screen_height = 1080;
            assign hsync_porch_start = 88;
            assign hsync_porch_size = 44;
            assign vsync_porch_start = 4;
            assign vsync_porch_size = 5;
            assign invert = 0;
        end
        17, 18:
        begin
            assign frame_width = 864;
            assign frame_height = 625;
            assign screen_width = 720;
            assign screen_height = 576;
            assign hsync_porch_start = 12;
            assign hsync_porch_size = 64;
            assign vsync_porch_start = 5;
            assign vsync_porch_size = 5;
            assign invert = 1;
        end
        19:
        begin
            assign frame_width = 1980;
            assign frame_height = 750;
            assign screen_width = 1280;
            assign screen_height = 720;
            assign hsync_porch_start = 440;
            assign hsync_porch_size = 40;
            assign vsync_porch_start = 5;
            assign vsync_porch_size = 5;
            assign invert = 0;
        end
        95, 105, 97, 107:
        begin
            assign frame_width = 4400;
            assign frame_height = 2250;
            assign screen_width = 3840;
            assign screen_height = 2160;
            assign hsync_porch_start = 176;
            assign hsync_porch_size = 88;
            assign vsync_porch_start = 8;
            assign vsync_porch_size = 10;
            assign invert = 0;
        end
    endcase
    assign hsync = invert ^ (cx >= screen_width + hsync_porch_start && cx < screen_width + hsync_porch_start + hsync_porch_size);
    assign vsync = invert ^ (cy >= screen_height + vsync_porch_start && cy < screen_height + vsync_porch_start + vsync_porch_size);
endgenerate    
    	

