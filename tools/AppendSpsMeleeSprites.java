import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import javax.imageio.ImageIO;

/** Appends the native SPS-PD 16x16 ordinary melee icons without resampling. */
public final class AppendSpsMeleeSprites {

	private static final int[][] SOURCES = {
			{160, 160}, {240, 160}, {160, 144}, {240, 144},
			{176, 144}, {256, 160}, {176, 160}, {256, 144},
			{272, 144}, {192, 144}, {272, 160}, {192, 160},
			{208, 160}, {208, 144}, {288, 160}, {288, 144},
			{224, 144}, {304, 160}, {304, 144}, {224, 160}
	};

	public static void main(String[] args) throws IOException {
		if (args.length != 2) throw new IllegalArgumentException("usage: source-items.png target-items.png");
		BufferedImage source = requireImage(new File(args[0]));
		File targetFile = new File(args[1]);
		BufferedImage target = requireImage(targetFile);
		if (source.getWidth() != 320 || source.getHeight() != 560) throw new IOException("unexpected SPS source sheet size");
		if (target.getWidth() != 256 || (target.getHeight() != 720 && target.getHeight() != 752)) throw new IOException("unexpected target sheet size");

		BufferedImage output = new BufferedImage(256, 752, BufferedImage.TYPE_INT_ARGB);
		copyPixels(target, output, 0, 0, 0, 0, 256, 720);
		for (int i = 0; i < SOURCES.length; i++) {
			copyPixels(source, output, SOURCES[i][0], SOURCES[i][1],
					(i % 16) * 16, 720 + (i / 16) * 16, 16, 16);
		}

		File temp = new File(targetFile.getParentFile(), targetFile.getName() + ".tmp");
		if (!ImageIO.write(output, "png", temp)) throw new IOException("PNG writer unavailable");
		Files.move(temp.toPath(), targetFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
		for (int i = 0; i < SOURCES.length; i++) {
			System.out.println(iconHash(output, (i % 16) * 16, 720 + (i / 16) * 16));
		}
	}

	private static String iconHash(BufferedImage image, int left, int top) throws IOException {
		try {
			ByteBuffer pixels = ByteBuffer.allocate(16 * 16 * 4).order(ByteOrder.LITTLE_ENDIAN);
			for (int y = top; y < top + 16; y++) {
				for (int x = left; x < left + 16; x++) pixels.putInt(image.getRGB(x, y));
			}
			StringBuilder result = new StringBuilder(64);
			for (byte value : MessageDigest.getInstance("SHA-256").digest(pixels.array())) {
				result.append(String.format("%02X", value & 0xFF));
			}
			return result.toString();
		} catch (NoSuchAlgorithmException exception) {
			throw new IOException(exception);
		}
	}

	private static BufferedImage requireImage(File file) throws IOException {
		BufferedImage image = ImageIO.read(file);
		if (image == null) throw new IOException("not a readable image: " + file);
		return image;
	}

	private static void copyPixels(BufferedImage source, BufferedImage target,
			int sourceX, int sourceY, int targetX, int targetY, int width, int height) {
		for (int y = 0; y < height; y++) {
			for (int x = 0; x < width; x++) {
				target.setRGB(targetX + x, targetY + y, source.getRGB(sourceX + x, sourceY + y));
			}
		}
	}

	private AppendSpsMeleeSprites() {
	}
}
