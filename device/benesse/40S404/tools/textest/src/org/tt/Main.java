package org.tt;

import android.app.Activity;
import android.graphics.Bitmap;
import android.graphics.SurfaceTexture;
import android.media.MediaPlayer;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.Surface;
import android.view.TextureView;

public class Main extends Activity implements TextureView.SurfaceTextureListener {
    static final String TAG = "TexTest";
    TextureView tv;
    MediaPlayer mp;
    int updates;
    Handler h = new Handler();

    @Override protected void onCreate(Bundle b) {
        super.onCreate(b);
        tv = new TextureView(this);
        tv.setSurfaceTextureListener(this);
        setContentView(tv);
    }

    @Override public void onSurfaceTextureAvailable(SurfaceTexture st, int w, int hh) {
        String f = getIntent().getStringExtra("f");
        if (f == null) f = "/sdcard/Movies/t720.mp4";
        try {
            mp = new MediaPlayer();
            mp.setDataSource(f);
            mp.setSurface(new Surface(st));
            mp.setLooping(true);
            mp.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
                public void onPrepared(MediaPlayer m) { m.start(); }
            });
            mp.prepareAsync();
        } catch (Exception e) { Log.e(TAG, "mp fail", e); }
        h.postDelayed(new Runnable() { public void run() { probe(); } }, 5000);
    }

    void probe() {
        Bitmap bm = tv.getBitmap();
        if (bm == null) { Log.i(TAG, "bitmap null"); return; }
        int w = bm.getWidth(), hh = bm.getHeight(), bright = 0, nonz = 0;
        int[] px = new int[w * hh];
        bm.getPixels(px, 0, w, 0, 0, w, hh);
        for (int p : px) {
            int r = (p >> 16) & 255, g = (p >> 8) & 255, bl = p & 255;
            if ((r + g + bl) > 600) bright++;
            if ((p & 0xffffff) != 0) nonz++;
        }
        Log.i(TAG, "bitmap " + w + "x" + hh + " nonzero=" + nonz + " bright=" + bright + " updates=" + updates
              + " pos=" + (mp != null ? mp.getCurrentPosition() : -1));
        h.postDelayed(new Runnable() { public void run() { probe(); } }, 3000);
    }

    @Override public void onSurfaceTextureSizeChanged(SurfaceTexture st, int w, int hh) {}
    @Override public boolean onSurfaceTextureDestroyed(SurfaceTexture st) { if (mp != null) { mp.release(); mp = null; } return true; }
    @Override public void onSurfaceTextureUpdated(SurfaceTexture st) { updates++; }
}
