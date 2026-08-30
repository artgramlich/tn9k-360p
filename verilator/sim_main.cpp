#include <iostream>
#include <memory>
#include <vector>
#include <SDL2/SDL.h>
#include <verilated.h>
#include "Vtop.h"
#include "Vtop___024root.h"

const int SCREEN_WIDTH = 640;
const int SCREEN_HEIGHT = 360;

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    auto top = std::make_unique<Vtop>();

    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        std::cerr << "SDL_Init Error: " << SDL_GetError() << std::endl;
        return 1;
    }

    SDL_Window* window = SDL_CreateWindow(
        "Simulation",
        SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
        // 2x scaling
        SCREEN_WIDTH * 2, SCREEN_HEIGHT * 2,
        SDL_WINDOW_SHOWN
    );
    if (!window) {
        std::cerr << "Window creation failed: " << SDL_GetError() << std::endl;
        SDL_Quit();
        return 1;
    }

    SDL_Renderer* renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
    if (!renderer) {
        std::cerr << "Renderer creation failed: " << SDL_GetError() << std::endl;
        SDL_DestroyWindow(window);
        SDL_Quit();
        return 1;
    }

    SDL_Texture* texture = SDL_CreateTexture(
        renderer, 
        SDL_PIXELFORMAT_ARGB8888, 
        SDL_TEXTUREACCESS_STREAMING, 
        SCREEN_WIDTH, SCREEN_HEIGHT
    );
    if (!texture) {
        std::cerr << "Texture creation failed: " << SDL_GetError() << std::endl;
        SDL_DestroyRenderer(renderer);
        SDL_DestroyWindow(window);
        SDL_Quit();
        return 1;
    }

    std::vector<uint32_t> pixel_buffer(SCREEN_WIDTH * SCREEN_HEIGHT, 0xFF000000);

    top->clk_27 = 0;
    top->rst_n = 0;

    uint64_t main_time = 0;
    bool old_clk_pixel = false;
    bool running = true;

    const int ENGINE_STEPS_PER_FRAME = 100000;
    int step_counter = 0;

    while (running) {
        SDL_Event event;
        while (SDL_PollEvent(&event)) {
            if (event.type == SDL_QUIT) {
                running = false;
            }
        }

        if (main_time > 500) {
            top->rst_n = 1;
        }

        top->clk_27 = !top->clk_27;
        top->eval();

        bool current_clk_pixel = top->rootp->top__DOT__clk_pixel;
        if (current_clk_pixel && !old_clk_pixel && top->rst_n == 1) {
            int px = top->rootp->top__DOT__x;
            int py = top->rootp->top__DOT__y;

            if (px < SCREEN_WIDTH && py < SCREEN_HEIGHT) {
                uint32_t raw_rgb = top->rootp->top__DOT__rgb_data;
                
                uint32_t r = (raw_rgb >> 16) & 0xFF;
                uint32_t g = (raw_rgb >> 8)  & 0xFF;
                uint32_t b = raw_rgb         & 0xFF;
                
                pixel_buffer[py * SCREEN_WIDTH + px] = (0xFF << 24) | (r << 16) | (g << 8) | b;
            }
        }
        old_clk_pixel = current_clk_pixel;

        if (++step_counter >= ENGINE_STEPS_PER_FRAME) {
            step_counter = 0;
            SDL_UpdateTexture(texture, nullptr, pixel_buffer.data(), SCREEN_WIDTH * sizeof(uint32_t));
            SDL_RenderClear(renderer);
            SDL_RenderCopy(renderer, texture, nullptr, nullptr);
            SDL_RenderPresent(renderer);
        }

        main_time++;
    }

    SDL_DestroyTexture(texture);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
    return 0;
}
