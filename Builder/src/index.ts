/* eslint-disable import-x/no-unused-modules */

import assert from 'node:assert';
import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

import { CASCClient, WDCReader, DBDParser } from '@rhyster/wow-casc-dbc';

import { latestVersion } from './client.ts';

interface XPLine {
    level: number,
    total: number,
    perKill: number,
    junk: number,
    stats: number,
    divisor: number,
}

interface ExperienceData {
    battleXP: number,
    totalXP: number,
}

const prevBuild = await fs.readFile('buildInfo.txt', 'utf-8').catch(() => '0');

const currBuild = latestVersion.version.BuildId;
assert(currBuild, 'Failed to get current build number');

if (process.argv[2] !== '--force' && prevBuild === currBuild) {
    console.info(new Date().toISOString(), `[INFO]: Build ${currBuild} is up to date`);
    process.exit(0);
}

const client = new CASCClient('us', latestVersion.product, latestVersion.version);
await client.init();

console.info(new Date().toISOString(), '[INFO]: Loading remote TACT keys');
await client.loadRemoteTACTKeys();
console.info(new Date().toISOString(), '[INFO]: Loaded remote TACT keys');

console.info(new Date().toISOString(), '[INFO]: Loading files');
const xpCKeys = client.getContentKeysByFileDataID(1391661); // gametables/xp.txt
assert(xpCKeys && xpCKeys.length > 0, 'No cKeys found for file gametables/xp.txt (1391661)');

const xpData = await client.getFileByContentKey(xpCKeys[0].cKey);

const questXPCKeys = client.getContentKeysByFileDataID(1139378); // dbfilesclient/questxp.db2
assert(questXPCKeys && questXPCKeys.length > 0, 'No cKeys found for file dbfilesclient/questxp.db2 (1139378)');

const questXPData = await client.getFileByContentKey(questXPCKeys[0].cKey);

const questXPReader = new WDCReader(questXPData.buffer, questXPData.blocks);
const questXPParser = await DBDParser.parse(questXPReader);
console.info(new Date().toISOString(), '[INFO]: Loaded files');

console.info(new Date().toISOString(), '[INFO]: Parsing files');
const xpLines = xpData.buffer.toString('utf-8').split('\n').map((line) => line.trim()).filter((line) => line.length > 0);
assert(xpLines[0] === 'Level\tTotal\tPerKill\tJunk\tStats\tDivisor', 'Unexpected header in xp.txt');

let maxLevel = Infinity;
const xpTable = new Map<number, XPLine>();
for (let i = 1; i < xpLines.length; i += 1) {
    const line = xpLines[i];
    const array = line.split('\t');
    assert(array.length === 6, `Unexpected number of columns in xp.txt line ${(i + 1).toString()}`);

    const xpLine: XPLine = {
        level: parseInt(array[0], 10),
        total: parseInt(array[1], 10),
        perKill: parseInt(array[2], 10),
        junk: parseInt(array[3], 10),
        stats: parseInt(array[4], 10),
        divisor: parseInt(array[5], 10),
    };
    xpTable.set(xpLine.level, xpLine);

    if (xpLine.total >= 99999999 && maxLevel > xpLine.level) {
        maxLevel = xpLine.level;
    }
}

const outputData: ExperienceData[] = [];
for (let level = 1; level < maxLevel; level += 1) {
    const xpLine = xpTable.get(level);
    assert(xpLine, `No xp data for level ${level.toString()}`);
    const totalXP = xpLine.total;

    const questRow = questXPParser.getRowData(level + 1);
    assert(questRow, `No quest xp data for level ${level.toString()}`);

    const difficulty = questRow.Difficulty as number[];

    if (level <= 5) {
        const battleXP = Math.round(difficulty[3] / 10) * 10;
        outputData.push({
            battleXP,
            totalXP,
        });
    } else if (level <= 14) {
        const battleXP = Math.round(difficulty[3] / 25) * 25;
        outputData.push({
            battleXP,
            totalXP,
        });
    } else {
        const battleXP = Math.round(difficulty[3] / 50) * 50;
        outputData.push({
            battleXP,
            totalXP,
        });
    }
}
console.info(new Date().toISOString(), '[INFO]: Parsed files');

console.info(new Date().toISOString(), '[INFO]: Updating addon file');
const outputDataText = `local experienceData = {\n${outputData.map(({ battleXP, totalXP }) => `    { battleXP = ${battleXP.toString()}, totalXP = ${totalXP.toString()} },`).join('\n')}\n}`;

const root = path.resolve(fileURLToPath(import.meta.url), '..', '..', '..');
const monitorFile = path.join(root, 'Monitor.lua');
const monitorFileText = await fs.readFile(monitorFile, 'utf-8');
const updatedMonitorFileText = monitorFileText.replace(/(?<=---AUTO_GENERATED LEADING ExperienceData\r?\n)((.|\r|\n)*)(?=\r?\n---AUTO_GENERATED TAILING ExperienceData)/g, outputDataText);
await fs.writeFile(monitorFile, updatedMonitorFileText);
console.info(new Date().toISOString(), '[INFO]: Updated addon file');

await fs.writeFile('buildInfo.txt', currBuild);

if (process.env.GITHUB_OUTPUT !== undefined) {
    await fs.writeFile(process.env.GITHUB_OUTPUT, `updated=true\nbuild=${currBuild}\n`, { flag: 'a' });
}
