import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import javax.imageio.ImageIO;

/** Imports the original SPS-PD NoomlinCrown icon without resampling. */
public final class ImportNoomlinCrownSprite {

	public static void main(String[] args) throws IOException {
		if (args.length != 2) throw new IllegalArgumentException("usage: source-items.png target-items.png");
		BufferedImage source = requireImage(new File(args[0]));
		File targetFile = new File(args[1]);
		BufferedImage target = requireImage(targetFile);
		if (source.getWidth() != 320 || source.getHeight() != 560) throw new IOException("unexpected SPS source sheet size");
		if (target.getWidth() != 256 || target.getHeight() != 976) throw new IOException("unexpected target sheet size");

		BufferedImage output = new BufferedImage(target.getWidth(), target.getHeight(), BufferedImage.TYPE_INT_ARGB);
		for (int y = 0; y < target.getHeight(); y++) {
			for (int x = 0; x < target.getWidth(); x++) output.setRGB(x, y, target.getRGB(x, y));
		}
		for (int y = 0; y < 16; y++) {
			for (int x = 0; x < 16; x++) output.setRGB(96 + x, 960 + y, source.getRGB(304 + x, 288 + y));
		}

		File temp = new File(targetFile.getParentFile(), targetFile.getName() + ".crown.tmp");
		if (!ImageIO.write(output, "png", temp)) throw new IOException("PNG writer unavailable");
		BufferedImage written = requireImage(temp);
		for (int y = 0; y < target.getHeight(); y++) {
			for (int x = 0; x < target.getWidth(); x++) {
				int expected = x >= 96 && x < 112 && y >= 960
						? source.getRGB(304 + x - 96, 288 + y - 960) : target.getRGB(x, y);
				if (written.getRGB(x, y) != expected) throw new IOException("pixel mismatch at " + x + "," + y);
			}
		}
		Files.move(temp.toPath(), targetFile.toPath(), StandardCopyOption.REPLACE_EXISTING);
		System.out.println(iconHash(written, 96, 960));
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

	private ImportNoomlinCrownSprite() { }
}
