// Full-screen EGL client that clears to a different solid colour every frame, so that a displayed
// frame that contains two colours is a torn composition.
//   sftest MODE FRAMES PERIOD_US
//   MODE bit0: glFinish() before eglSwapBuffers, bit1: glFinish() after eglSwapBuffers
#include <gui/SurfaceComposerClient.h>
#include <gui/Surface.h>
#include <gui/ISurfaceComposer.h>
#include <ui/DisplayInfo.h>
#include <EGL/egl.h>
#include <GLES2/gl2.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
using namespace android;

static const float kPal[8][3] = {
    {1,0,0},{0,1,0},{0,0,1},{1,1,0},{0,1,1},{1,0,1},{1,1,1},{1,0.5f,0}};

int main(int argc, char** argv) {
    int mode = argc > 1 ? atoi(argv[1]) : 0;
    int frames = argc > 2 ? atoi(argv[2]) : 600;
    int periodUs = argc > 3 ? atoi(argv[3]) : 0;
    sp<SurfaceComposerClient> client = new SurfaceComposerClient();
    if (client->initCheck() != NO_ERROR) { fprintf(stderr, "no SF\n"); return 1; }
    sp<SurfaceControl> sc = client->createSurface(String8("sftest"), 1024, 768,
            PIXEL_FORMAT_RGBA_8888, 0);
    if (sc == NULL || !sc->isValid()) { fprintf(stderr, "createSurface failed\n"); return 1; }
    SurfaceComposerClient::openGlobalTransaction();
    sc->setLayer(0x7fffffff);
    sc->setPosition(0, 0);
    sc->show();
    SurfaceComposerClient::closeGlobalTransaction();
    sp<Surface> surf = sc->getSurface();

    EGLDisplay dpy = eglGetDisplay(EGL_DEFAULT_DISPLAY);
    eglInitialize(dpy, NULL, NULL);
    EGLint cfgAttr[] = { EGL_SURFACE_TYPE, EGL_WINDOW_BIT, EGL_RENDERABLE_TYPE, EGL_OPENGL_ES2_BIT,
            EGL_RED_SIZE, 8, EGL_GREEN_SIZE, 8, EGL_BLUE_SIZE, 8, EGL_ALPHA_SIZE, 8, EGL_NONE };
    EGLConfig cfg; EGLint n;
    if (!eglChooseConfig(dpy, cfgAttr, &cfg, 1, &n) || n < 1) { fprintf(stderr, "no config\n"); return 1; }
    EGLint ctxAttr[] = { EGL_CONTEXT_CLIENT_VERSION, 2, EGL_NONE };
    EGLContext ctx = eglCreateContext(dpy, cfg, EGL_NO_CONTEXT, ctxAttr);
    EGLSurface es = eglCreateWindowSurface(dpy, cfg, surf.get(), NULL);
    if (es == EGL_NO_SURFACE || !eglMakeCurrent(dpy, es, es, ctx)) { fprintf(stderr, "egl failed %x\n", eglGetError()); return 1; }
    eglSwapInterval(dpy, 1);
    int passes = argc > 4 ? atoi(argv[4]) : 0;
    GLuint prog = 0, uCol = 0;
    if (passes > 0) {
        const char* vs = "attribute vec2 p; void main(){ gl_Position = vec4(p, 0.0, 1.0); }";
        const char* fs = "precision mediump float; uniform vec4 col; void main(){ gl_FragColor = col; }";
        GLuint v = glCreateShader(GL_VERTEX_SHADER); glShaderSource(v, 1, &vs, NULL); glCompileShader(v);
        GLuint f = glCreateShader(GL_FRAGMENT_SHADER); glShaderSource(f, 1, &fs, NULL); glCompileShader(f);
        prog = glCreateProgram(); glAttachShader(prog, v); glAttachShader(prog, f);
        glBindAttribLocation(prog, 0, "p"); glLinkProgram(prog); glUseProgram(prog);
        uCol = glGetUniformLocation(prog, "col");
    }
    for (int i = 0; i < frames; i++) {
        const float* c = kPal[i % 8];
        if (passes > 0) {
            static const float quad[] = { -1,-1, 1,-1, -1,1, 1,1 };
            glDisable(GL_BLEND);
            glEnableVertexAttribArray(0); glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 0, quad);
            glUniform4f(uCol, c[0], c[1], c[2], 1.0f);
            for (int k = 0; k < passes; k++) glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        } else {
            glClearColor(c[0], c[1], c[2], 1.0f);
            glClear(GL_COLOR_BUFFER_BIT);
        }
        if (mode & 1) glFinish();
        eglSwapBuffers(dpy, es);
        if (mode & 2) glFinish();
        if (periodUs) usleep(periodUs);
    }
    printf("sftest done %d frames mode %d\n", frames, mode);
    return 0;
}
